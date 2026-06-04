import 'package:flutter/material.dart';

import '../../../core/routes.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOrderCard(
            theme,
            'سباكة',
            'إصلاح حنفية المطبخ',
            '200 EGP',
            'تم الانتهاء',
            true,
            () => Navigator.pushNamed(context, AppRoutes.orderTracking),
          ),
          const SizedBox(height: 12),
          _buildOrderCard(
            theme,
            'تكييف',
            'صيانة دورية',
            '350 EGP',
            'قيد التنفيذ',
            false,
            () => Navigator.pushNamed(context, AppRoutes.orderTracking),
          ),
          const SizedBox(height: 12),
          _buildOrderCard(
            theme,
            'توصيل',
            'طلب من بقالة',
            '50 EGP',
            'تم الانتهاء',
            true,
            () => Navigator.pushNamed(context, AppRoutes.orderTracking),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
    ThemeData theme,
    String service,
    String description,
    String price,
    String status,
    bool completed,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.handyman_rounded,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(service, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(price, style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: completed
                        ? theme.colorScheme.tertiaryContainer
                        : theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      color: completed
                          ? theme.colorScheme.onTertiaryContainer
                          : theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
      ),
    );
  }
}
