import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/routes.dart';
import '../../features/orders/services/order_service.dart';
import '../../models/review_model.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../cubit/provider_auth_cubit.dart';
import '../cubit/provider_auth_state.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProviderAuthCubit, ProviderAuthState>(
      builder: (context, state) {
        if (state is! ProviderAuthVerified) {
          return const SizedBox.shrink();
        }
        final provider = state.provider;
        return Scaffold(
          appBar: AppBar(
            title: const Text('حسابي'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                onPressed: () {
                  context.read<ProviderAuthCubit>().signOut();
                    Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (_) => false,
                  );
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        provider.name.isNotEmpty
                            ? provider.name[0].toUpperCase()
                            : '?',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(provider.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(provider.phone,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Card(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الخدمات',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: provider.services.map((s) {
                          return Chip(
                            label: Text(s),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer,
                          );
                        }).toList(),
                      ),
                      if (provider.services.isEmpty)
                        Text('لا توجد خدمات محددة',
                            style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.star_rounded,
                      label: 'التقييم',
                      value: provider.rating > 0
                          ? provider.rating.toStringAsFixed(1)
                          : 'جديد',
                      valueColor: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.receipt_long_rounded,
                      label: 'الطلبات',
                      value: '${provider.totalOrders}',
                      valueColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('التقييمات',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _RecentReviews(providerId: provider.id),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<ProviderAuthCubit>().signOut();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (_) => false,
                    );
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('تسجيل الخروج'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade300),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: valueColor),
            const SizedBox(height: 8),
            Text(value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: valueColor,
                    )),
            Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
          ],
        ),
      ),
    );
  }
}

class _RecentReviews extends StatelessWidget {
  final String providerId;
  const _RecentReviews({required this.providerId});

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService();
    return StreamBuilder<List<ReviewModel>>(
      stream: orderService.providerReviewsStream(providerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(itemCount: 2);
        }
        final reviews = snapshot.data ?? [];
        if (reviews.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.rate_review_outlined,
            title: 'لا توجد تقييمات بعد',
            subtitle: 'عند تقييم العملاء لك ستظهر هنا',
          );
        }
        return Column(
          children: reviews.take(5).map((r) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.amber.shade50,
                child: Text(
                  '${r.rating}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade700,
                  ),
                ),
              ),
              title: r.comment != null ? Text(r.comment!) : null,
              subtitle: Text(
                'منذ ${DateTime.now().difference(r.createdAt).inDays} يوم',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
