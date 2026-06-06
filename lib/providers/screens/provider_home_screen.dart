import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/location_service.dart';
import '../../core/routes.dart';
import '../../features/orders/services/order_service.dart';
import '../../models/order_model.dart';
import '../../shared/widgets/loading_widget.dart';
import '../cubit/provider_auth_cubit.dart';
import '../cubit/provider_auth_state.dart';
import '../services/provider_service.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  StreamSubscription? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  void _startLocationUpdates() {
    final provider = context.read<ProviderAuthCubit>().state;
    if (provider is! ProviderAuthVerified) return;
    if (!provider.provider.available) return;

    _locationSubscription =
        Stream.periodic(const Duration(seconds: 30)).listen((_) async {
      try {
        final location = await LocationService().getCurrentLocation();
        if (location != null) {
          await ProviderService().updateLocation(
            provider.provider.id,
            location.latitude,
            location.longitude,
          );
        }
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProviderAuthCubit, ProviderAuthState>(
      builder: (context, state) {
        if (state is! ProviderAuthVerified) {
          return const SizedBox.shrink();
        }
        return _ProviderHomeBody(provider: state.provider);
      },
    );
  }
}

class _ProviderHomeBody extends StatefulWidget {
  final dynamic provider;

  const _ProviderHomeBody({required this.provider});

  @override
  State<_ProviderHomeBody> createState() => _ProviderHomeBodyState();
}

class _ProviderHomeBodyState extends State<_ProviderHomeBody> {
  final _orderService = OrderService();
  final _providerService = ProviderService();
  double _todayEarnings = 0;
  int _todayOrders = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    _providerService.getTodayEarnings(widget.provider.id).then((v) {
      if (mounted) setState(() => _todayEarnings = v);
    });
    _orderService
        .providerOrdersStream(widget.provider.id)
        .firstWhere((orders) => orders.isNotEmpty)
        .then((orders) {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final todayOrders =
          orders.where((o) => o.createdAt.isAfter(startOfDay)).length;
      if (mounted) setState(() => _todayOrders = todayOrders);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إيد واحدة — مقدم الخدمة'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.providerProfile),
          ),
        ],
      ),
      body: StreamBuilder<dynamic>(
        stream: _providerService.streamProvider(widget.provider.id),
        builder: (context, snapshot) {
          final provider = snapshot.data ?? widget.provider;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _AvailabilityCard(provider: provider),
              const SizedBox(height: 16),
              _ActiveOrderCard(
                providerId: widget.provider.id,
                orderService: _orderService,
              ),
              const SizedBox(height: 16),
              _StatsRow(
                todayOrders: _todayOrders,
                todayEarnings: _todayEarnings,
                commission: provider.commission,
              ),
              const SizedBox(height: 16),
              _QuickActions(providerId: widget.provider.id),
            ],
          );
        },
      ),
      bottomNavigationBar: _ProviderBottomNav(selectedIndex: 0),
    );
  }
}

class _AvailabilityCard extends StatelessWidget {
  final dynamic provider;
  const _AvailabilityCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: provider.available ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.available ? 'أنت متصل الآن' : 'أنت غير متصل',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    provider.available
                        ? 'يمكنك استقبال الطلبات'
                        : 'لن تظهر لك طلبات جديدة',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Switch(
              value: provider.available,
              onChanged: (v) {
                ProviderService().updateAvailability(provider.id, v);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  final String providerId;
  final OrderService orderService;

  const _ActiveOrderCard({
    required this.providerId,
    required this.orderService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OrderModel>>(
      stream: orderService.providerOrdersStream(providerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(itemCount: 1);
        }
        final orders = snapshot.data ?? [];
        final active = orders.where(
          (o) =>
              o.status == OrderStatus.accepted ||
              o.status == OrderStatus.inProgress,
        );
        if (active.isEmpty) return const SizedBox.shrink();

        final order = active.first;
        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.engineering_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'الطلب النشط',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: order.status == OrderStatus.accepted
                            ? Colors.orange.shade100
                            : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.status.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: order.status == OrderStatus.accepted
                              ? Colors.orange.shade800
                              : Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(order.serviceType,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(order.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Text('${order.price} EGP',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        )),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.orderTracking,
                      arguments: order.id,
                    ),
                    child: const Text('عرض تفاصيل الطلب'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int todayOrders;
  final double todayEarnings;
  final double commission;

  const _StatsRow({
    required this.todayOrders,
    required this.todayEarnings,
    required this.commission,
  });

  @override
  Widget build(BuildContext context) {
    final netEarnings = todayEarnings * (1 - commission);
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_rounded,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 8),
                  Text('$todayOrders',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                  Text('طلبات اليوم',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.monetization_on_rounded,
                      color: Colors.green.shade700),
                  const SizedBox(height: 8),
                  Text('${netEarnings.toStringAsFixed(0)} EGP',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                  Text('صافي أرباح اليوم',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  final String providerId;
  const _QuickActions({required this.providerId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.list_alt_rounded,
            label: 'الطلبات',
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.providerOrders),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.trending_up_rounded,
            label: 'الأرباح',
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.providerEarnings),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.person_outline,
            label: 'حسابي',
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.providerProfile),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderBottomNav extends StatelessWidget {
  final int selectedIndex;
  const _ProviderBottomNav({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'الرئيسية'),
        NavigationDestination(
            icon: Icon(Icons.list_alt_outlined), label: 'الطلبات'),
        NavigationDestination(
            icon: Icon(Icons.trending_up_outlined), label: 'الأرباح'),
        NavigationDestination(
            icon: Icon(Icons.person_outline), label: 'حسابي'),
      ],
      onDestinationSelected: (i) {
        if (i == 0) return;
        if (i == 1) Navigator.pushNamed(context, AppRoutes.providerOrders);
        if (i == 2) Navigator.pushNamed(context, AppRoutes.providerEarnings);
        if (i == 3) Navigator.pushNamed(context, AppRoutes.providerProfile);
      },
    );
  }
}
