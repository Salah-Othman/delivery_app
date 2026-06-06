import 'package:flutter/material.dart';

import '../../../core/error_utils.dart';
import '../../../models/order_model.dart';
import '../../../models/review_model.dart';
import '../services/order_service.dart';

class ReviewScreen extends StatefulWidget {
  final OrderModel order;
  const ReviewScreen({super.key, required this.order});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('تقييم الخدمة')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 24),
          Icon(
            Icons.star_rounded,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'كيف كانت الخدمة؟',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'قم بتقييم الخدمة التي تلقيتها من مقدم الخدمة',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final starIndex = i + 1;
              return IconButton(
                onPressed:
                    _submitting ? null : () => setState(() => _rating = starIndex),
                icon: Icon(
                  starIndex <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 48,
                  color: starIndex <= _rating
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _commentController,
            maxLines: 4,
            textDirection: TextDirection.rtl,
            enabled: !_submitting,
            decoration: InputDecoration(
              hintText: 'اكتب تعليقك (اختياري)...',
              hintTextDirection: TextDirection.rtl,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _submitting || _rating == 0 ? null : _submitReview,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('إرسال التقييم'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReview() async {
    if (widget.order.providerId == null) return;

    setState(() => _submitting = true);

    try {
      final review = ReviewModel(
        id: '',
        orderId: widget.order.id,
        userId: widget.order.userId,
        providerId: widget.order.providerId!,
        rating: _rating,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      );

      final orderService = OrderService();
      await orderService.addReview(review);

      if (mounted) {
        showSuccessSnackBar(context, 'تم إرسال التقييم، شكراً لك!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'حدث خطأ أثناء إرسال التقييم');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
