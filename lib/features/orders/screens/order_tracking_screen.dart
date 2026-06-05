import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/order_model.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../orders/services/order_service.dart';
import 'review_screen.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderId = ModalRoute.of(context)?.settings.arguments as String?;
    if (orderId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('متابعة الطلب')),
        body: const AppErrorWidget(message: 'معرف الطلب غير موجود'),
      );
    }

    final orderService = OrderService();
    return Scaffold(
      appBar: AppBar(title: const Text('متابعة الطلب')),
      body: StreamBuilder<OrderModel?>(
        stream: orderService.orderStream(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const AppErrorWidget(
              message: 'حدث خطأ في تحميل بيانات الطلب',
            );
          }
          final order = snapshot.data;
          if (order == null) {
            return const AppErrorWidget(message: 'الطلب غير موجود');
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _OrderMapCard(order: order),
              const SizedBox(height: 16),
              _StatusCard(order: order),
              const SizedBox(height: 16),
              _OrderDetailsCard(order: order),
              const SizedBox(height: 24),
              if (order.status == OrderStatus.completed)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReviewScreen(order: order),
                      ),
                    ),
                    icon: const Icon(Icons.star_rounded),
                    label: const Text('تقييم مقدم الخدمة'),
                  ),
                ),
              if (order.providerId != null &&
                  order.status != OrderStatus.completed &&
                  order.status != OrderStatus.cancelled)
                const SizedBox(height: 12),
              if (order.providerId != null &&
                  order.status != OrderStatus.completed &&
                  order.status != OrderStatus.cancelled)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => _callProvider(context, order),
                    icon: const Icon(Icons.phone_rounded),
                    label: const Text('اتصل بمقدم الخدمة'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _callProvider(BuildContext context, OrderModel order) async {
    // TODO: Fetch provider phone from Firestore and pass it here
    // For now, prompt user to call the provider directly
    final uri = Uri.parse('tel:');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _OrderMapCard extends StatelessWidget {
  final OrderModel order;
  const _OrderMapCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCoords = order.userLat != null && order.userLng != null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_rounded,
                    size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order.userAddress ?? 'العنوان: غير محدد',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 180,
                child: hasCoords
                    ? FlutterMap(
                        options: MapOptions(
                          initialCenter:
                              LatLng(order.userLat!, order.userLng!),
                          initialZoom: 15,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.all,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'app_delivery',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point:
                                    LatLng(order.userLat!, order.userLng!),
                                width: 40,
                                height: 40,
                                child: Icon(
                                  Icons.location_on_rounded,
                                  size: 40,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map_outlined,
                                size: 48,
                                color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(height: 8),
                            Text(
                              'الموقع غير محدد',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final OrderModel order;
  const _StatusCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final steps = [
      _StatusStep('تم استلام الطلب', order.status.index >= OrderStatus.pending.index),
      _StatusStep('تم قبول الطلب', order.status.index >= OrderStatus.accepted.index),
      _StatusStep('مقدم الخدمة في الطريق',
          order.status.index >= OrderStatus.inProgress.index),
      _StatusStep('جارٍ العمل', order.status.index >= OrderStatus.inProgress.index),
      _StatusStep('تم الانتهاء', order.status.index >= OrderStatus.completed.index),
    ];

    if (order.status == OrderStatus.cancelled) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.error),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.cancel_rounded, color: theme.colorScheme.error),
              const SizedBox(width: 12),
              Text('تم إلغاء الطلب',
                  style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (order.providerId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(Icons.person,
                          color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('مقدم الخدمة',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('تم تعيين مقدم خدمة',
                            style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(order.status.label,
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ...steps.asMap().entries.map(
                  (entry) => _buildStepRow(theme, entry.value, entry.key),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(ThemeData theme, _StatusStep step, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            step.completed ? Icons.check_circle : Icons.circle_outlined,
            size: 20,
            color: step.completed
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
          const SizedBox(width: 12),
          Text(
            step.label,
            style: TextStyle(
              color: step.completed
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetailsCard extends StatelessWidget {
  final OrderModel order;
  const _OrderDetailsCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تفاصيل الطلب',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(),
            _DetailRow(label: 'الخدمة', value: order.serviceType),
            _DetailRow(label: 'الوصف', value: order.description),
            _DetailRow(
              label: 'السعر',
              value: '${order.price} EGP',
            ),
            _DetailRow(label: 'طريقة الدفع', value: order.paymentMethod.label),
            _DetailRow(
              label: 'تاريخ الطلب',
              value: '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Expanded(child: Text(value, textAlign: TextAlign.start)),
        ],
      ),
    );
  }
}

class _StatusStep {
  final String label;
  final bool completed;
  _StatusStep(this.label, this.completed);
}
