import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/widgets/loading_widget.dart';
import '../cubit/provider_auth_cubit.dart';
import '../cubit/provider_auth_state.dart';
import '../services/provider_service.dart';

class ProviderEarningsScreen extends StatefulWidget {
  const ProviderEarningsScreen({super.key});

  @override
  State<ProviderEarningsScreen> createState() => _ProviderEarningsScreenState();
}

class _ProviderEarningsScreenState extends State<ProviderEarningsScreen> {
  final _providerService = ProviderService();
  double _todayEarnings = 0;
  double _weekEarnings = 0;
  double _monthEarnings = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  void _loadEarnings() {
    final state = context.read<ProviderAuthCubit>().state;
    if (state is! ProviderAuthVerified) return;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final startOfMonth = DateTime(now.year, now.month, 1);

    Future.wait([
      _providerService.getTodayEarnings(state.provider.id),
      _providerService.getPeriodEarnings(
          state.provider.id, startOfWeekDay, startOfDay.add(const Duration(days: 1))),
      _providerService.getPeriodEarnings(
          state.provider.id, startOfMonth, startOfDay.add(const Duration(days: 1))),
    ]).then((results) {
      if (mounted) {
        setState(() {
          _todayEarnings = results[0];
          _weekEarnings = results[1];
          _monthEarnings = results[2];
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProviderAuthCubit, ProviderAuthState>(
      builder: (context, state) {
        if (state is! ProviderAuthVerified) {
          return const SizedBox.shrink();
        }
        return Scaffold(
          appBar: AppBar(title: const Text('الأرباح')),
          body: _loading
              ? const LoadingWidget(itemCount: 4)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _EarningsSummaryCard(
                      title: 'أرباح اليوم',
                      earnings: _todayEarnings,
                      commission: state.provider.commission,
                      icon: Icons.today_rounded,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _EarningsSummaryCard(
                      title: 'أرباح الأسبوع',
                      earnings: _weekEarnings,
                      commission: state.provider.commission,
                      icon: Icons.date_range_rounded,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _EarningsSummaryCard(
                      title: 'أرباح الشهر',
                      earnings: _monthEarnings,
                      commission: state.provider.commission,
                      icon: Icons.calendar_month_rounded,
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 12),
                    _EarningsSummaryCard(
                      title: 'الإجمالي الكلي',
                      earnings: state.provider.totalEarnings,
                      commission: 0,
                      icon: Icons.account_balance_wallet_rounded,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color:
                              Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('نسبة العمولة',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                              'يتم خصم ${(state.provider.commission * 100).toStringAsFixed(0)}% من كل طلب كعمولة للتطبيق',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
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

class _EarningsSummaryCard extends StatelessWidget {
  final String title;
  final double earnings;
  final double commission;
  final IconData icon;
  final Color color;

  const _EarningsSummaryCard({
    required this.title,
    required this.earnings,
    required this.commission,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final netEarnings = earnings * (1 - commission);
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          )),
                  const SizedBox(height: 4),
                  Text(
                    '${netEarnings.toStringAsFixed(0)} EGP',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (commission > 0)
                    Text(
                      'إجمالي: ${earnings.toStringAsFixed(0)} EGP (خصم ${(commission * 100).toStringAsFixed(0)}%)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
