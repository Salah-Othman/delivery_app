import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants.dart';
import '../../../core/routes.dart';
import '../../../models/service_category.dart';
import '../../../models/order_model.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../orders/services/order_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final _categories = AppCategories.categories.map((c) {
    final icon = _iconMap[c.icon] ?? Icons.handyman_rounded;
    return _ServiceCategory(c.name, icon);
  }).toList();

  static const _iconMap = {
    'ac_unit': Icons.ac_unit_rounded,
    'water_drop': Icons.water_drop_rounded,
    'bolt': Icons.bolt_rounded,
    'handyman': Icons.handyman_rounded,
    'format_paint': Icons.format_paint_rounded,
    'delivery_dining': Icons.delivery_dining_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is AuthVerified ? state.user : null;
        return Scaffold(
          appBar: AppBar(
            title: const Text(AppConstants.appName),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (user?.name != null) ...[
                Text(
                  'مرحباً، ${user!.name}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                decoration: InputDecoration(
                  hintText: 'إبحث عن خدمة...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'الخدمات',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: _categories.length,
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.newOrder,
                      arguments: cat.name,
                    ),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(cat.icon, size: 32),
                          const SizedBox(height: 8),
                          Text(cat.name, style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'طلباتي',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.orderHistory),
                    child: const Text('عرض الكل'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (user != null)
                _RecentOrders(userId: user.id)
              else
                const EmptyStateWidget(
                  icon: Icons.login_rounded,
                  title: 'سجل الدخول لعرض طلباتك',
                ),
            ],
          ),
          bottomNavigationBar: const _HomeBottomNav(selectedIndex: 0),
        );
      },
    );
  }
}

class _RecentOrders extends StatelessWidget {
  final String userId;
  const _RecentOrders({required this.userId});

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService();
    return StreamBuilder<List<OrderModel>>(
      stream: orderService.userOrdersStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(itemCount: 2);
        }
        if (snapshot.hasError) {
          return const EmptyStateWidget(
            icon: Icons.error_outline_rounded,
            title: 'حدث خطأ أثناء تحميل الطلبات',
          );
        }
        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.receipt_long_outlined,
            title: 'لا توجد طلبات حالياً',
            subtitle: 'اطلب خدمة جديدة من التصنيفات أعلاه',
          );
        }
        return Column(
          children: orders.take(3).map((order) => _OrderCard(order: order)).toList(),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
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
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.handyman_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(order.serviceType,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${order.price} EGP • ${order.status.label}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: const Icon(Icons.chevron_left),
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.orderTracking,
          arguments: order.id,
        ),
      ),
    );
  }
}

class _HomeBottomNav extends StatelessWidget {
  final int selectedIndex;
  const _HomeBottomNav({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'الرئيسية'),
        NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined), label: 'طلباتي'),
        NavigationDestination(
            icon: Icon(Icons.person_outline), label: 'حسابي'),
      ],
      onDestinationSelected: (i) {
        if (i == 1) Navigator.pushNamed(context, AppRoutes.orderHistory);
        if (i == 2) Navigator.pushNamed(context, AppRoutes.profile);
      },
    );
  }
}

class _ServiceCategory {
  final String name;
  final IconData icon;
  const _ServiceCategory(this.name, this.icon);
}
