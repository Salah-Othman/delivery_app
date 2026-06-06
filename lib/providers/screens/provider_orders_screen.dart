import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/error_utils.dart';
import '../../core/routes.dart';
import '../../features/orders/services/order_service.dart';
import '../../models/order_model.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../cubit/provider_auth_cubit.dart';
import '../cubit/provider_auth_state.dart';
import '../services/provider_service.dart';

class ProviderOrdersScreen extends StatefulWidget {
  const ProviderOrdersScreen({super.key});

  @override
  State<ProviderOrdersScreen> createState() => _ProviderOrdersScreenState();
}

class _ProviderOrdersScreenState extends State<ProviderOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProviderAuthCubit, ProviderAuthState>(
      builder: (context, state) {
        if (state is! ProviderAuthVerified) {
          return const SizedBox.shrink();
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('الطلبات'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'جديدة'),
                Tab(text: 'نشط'),
                Tab(text: 'سابق'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _PendingOrdersTab(
                providerId: state.provider.id,
                providerServices: state.provider.services,
                orderService: _orderService,
              ),
              _ActiveOrdersTab(
                providerId: state.provider.id,
                orderService: _orderService,
              ),
              _OrderHistoryTab(
                providerId: state.provider.id,
                orderService: _orderService,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PendingOrdersTab extends StatelessWidget {
  final String providerId;
  final List<String> providerServices;
  final OrderService orderService;

  const _PendingOrdersTab({
    required this.providerId,
    required this.providerServices,
    required this.orderService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OrderModel>>(
      stream: orderService.providerOrdersStream(providerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(itemCount: 3);
        }
        final orders = snapshot.data ?? [];
        final pending = orders
            .where((o) => o.status == OrderStatus.pending)
            .where((o) =>
                providerServices.isEmpty ||
                providerServices.contains(o.serviceType))
            .toList();

        if (pending.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.inbox_rounded,
            title: 'لا توجد طلبات جديدة',
            subtitle: 'ستظهر الطلبات الجديدة هنا',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pending.length,
          itemBuilder: (_, i) => _PendingOrderCard(
            order: pending[i],
            providerId: providerId,
            orderService: orderService,
          ),
        );
      },
    );
  }
}

class _PendingOrderCard extends StatelessWidget {
  final OrderModel order;
  final String providerId;
  final OrderService orderService;

  const _PendingOrderCard({
    required this.order,
    required this.providerId,
    required this.orderService,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.handyman_rounded,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(order.serviceType,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${order.price} EGP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    )),
              ],
            ),
            const SizedBox(height: 8),
            Text(order.description,
                maxLines: 3, overflow: TextOverflow.ellipsis),
            if (order.userAddress != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(order.userAddress!,
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade300),
                    ),
                    child: const Text('رفض'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      orderService.assignProvider(order.id, providerId)
                          .then((_) {
                        if (context.mounted) {
                          showSuccessSnackBar(context, 'تم قبول الطلب بنجاح');
                        }
                      }).catchError((e) {
                        if (context.mounted) {
                          showErrorSnackBar(context, 'حدث خطأ أثناء قبول الطلب');
                        }
                      });
                    },
                    child: const Text('قبول'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveOrdersTab extends StatelessWidget {
  final String providerId;
  final OrderService orderService;

  const _ActiveOrdersTab({
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
        if (active.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.play_circle_outline,
            title: 'لا يوجد طلب نشط',
            subtitle: 'عند قبول طلب سيظهر هنا',
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: active
              .map((o) => _ActiveOrderCard(
                    order: o,
                    providerId: providerId,
                    orderService: orderService,
                  ))
              .toList(),
        );
      },
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  final OrderModel order;
  final String providerId;
  final OrderService orderService;

  const _ActiveOrderCard({
    required this.order,
    required this.providerId,
    required this.orderService,
  });

  @override
  Widget build(BuildContext context) {
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
                Text(order.serviceType,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            const SizedBox(height: 8),
            Text(order.description, maxLines: 3),
            const SizedBox(height: 8),
            Text('${order.price} EGP',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                )),
            const SizedBox(height: 12),
            if (order.status == OrderStatus.accepted)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    orderService.updateOrderStatus(
                            order.id, OrderStatus.inProgress)
                        .then((_) {
                      if (context.mounted) {
                        showSuccessSnackBar(context, 'تم بدء العمل');
                      }
                    }).catchError((e) {
                      if (context.mounted) {
                        showErrorSnackBar(context, 'حدث خطأ');
                      }
                    });
                  },
                  child: const Text('بدء العمل'),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Future.wait([
                      orderService.updateOrderStatus(
                          order.id, OrderStatus.completed),
                      ProviderService().incrementOrders(providerId),
                      ProviderService().addEarnings(providerId, order.price),
                    ]).then((_) {
                      if (context.mounted) {
                        showSuccessSnackBar(context, 'تم إكمال الطلب');
                      }
                    }).catchError((e) {
                      if (context.mounted) {
                        showErrorSnackBar(context, 'حدث خطأ');
                      }
                    });
                  },
                  child: const Text('تم الانتهاء'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OrderHistoryTab extends StatelessWidget {
  final String providerId;
  final OrderService orderService;

  const _OrderHistoryTab({
    required this.providerId,
    required this.orderService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OrderModel>>(
      stream: orderService.providerOrdersStream(providerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(itemCount: 3);
        }
        final orders = snapshot.data ?? [];
        final completed = orders.where(
          (o) =>
              o.status == OrderStatus.completed ||
              o.status == OrderStatus.cancelled,
        );
        if (completed.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.history_rounded,
            title: 'لا توجد طلبات سابقة',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: completed.length,
          itemBuilder: (_, i) {
            final o = completed.elementAt(i);
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: o.status == OrderStatus.completed
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    o.status == OrderStatus.completed
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: o.status == OrderStatus.completed
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                title: Text(o.serviceType,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${o.price} EGP • ${o.status.label}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.orderTracking,
                  arguments: o.id,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
