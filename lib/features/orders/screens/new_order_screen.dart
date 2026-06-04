import 'package:flutter/material.dart';

import '../../../core/routes.dart';

class NewOrderScreen extends StatelessWidget {
  const NewOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلب خدمة جديدة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'اختر الخدمة',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            items: const [
              DropdownMenuItem(value: 'سباكة', child: Text('سباكة')),
              DropdownMenuItem(value: 'كهرباء', child: Text('كهرباء')),
              DropdownMenuItem(value: 'تكييف', child: Text('تكييف')),
              DropdownMenuItem(value: 'نجارة', child: Text('نجارة')),
              DropdownMenuItem(value: 'دهان', child: Text('دهان')),
              DropdownMenuItem(value: 'توصيل', child: Text('توصيل')),
            ],
            onChanged: (_) {},
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'وصف المشكلة',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            maxLines: 4,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'اكتب وصف للمشكلة بالتفصيل...',
              hintTextDirection: TextDirection.rtl,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'العنوان',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'شارع البحر، أبو قرقاص',
              hintTextDirection: TextDirection.rtl,
              prefixIcon: const Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'السعر المقترح',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'مثلاً: 200',
              prefixIcon: const Icon(Icons.attach_money),
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
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.orderTracking),
              child: const Text('إرسال الطلب'),
            ),
          ),
        ],
      ),
    );
  }
}
