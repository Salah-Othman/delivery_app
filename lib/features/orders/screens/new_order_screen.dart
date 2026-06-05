import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/routes.dart';
import '../../../models/order_model.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../cubit/order_cubit.dart';
import '../cubit/order_state.dart';
import 'map_picker_screen.dart';

class NewOrderScreen extends StatefulWidget {
  final OrderCubit? orderCubit;

  const NewOrderScreen({super.key, this.orderCubit});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedService = 'سباكة';
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  double? _selectedLat;
  double? _selectedLng;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty) {
      _selectedService = args;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => widget.orderCubit ?? OrderCubit(),
      child: BlocConsumer<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderCreated) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.orderTracking,
              (route) => route.settings.name == AppRoutes.home,
              arguments: state.orderId,
            );
          } else if (state is OrderError) {
            _showSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          final loading = state is OrderLoading;
          return Scaffold(
            appBar: AppBar(title: const Text('طلب خدمة جديدة')),
            body: Form(
              key: _formKey,
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  _SectionLabel(text: 'اختر الخدمة'),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedService,
                    items: const [
                      DropdownMenuItem(value: 'سباكة', child: Text('سباكة')),
                      DropdownMenuItem(value: 'كهرباء', child: Text('كهرباء')),
                      DropdownMenuItem(value: 'تكييف', child: Text('تكييف')),
                      DropdownMenuItem(value: 'نجارة', child: Text('نجارة')),
                      DropdownMenuItem(value: 'دهان', child: Text('دهان')),
                      DropdownMenuItem(value: 'توصيل', child: Text('توصيل')),
                    ],
                    onChanged: loading
                        ? null
                        : (v) => setState(() => _selectedService = v!),
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel(text: 'وصف المشكلة'),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    textDirection: TextDirection.rtl,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'اكتب وصف المشكلة' : null,
                    decoration: const InputDecoration(
                      hintText: 'اكتب وصف للمشكلة بالتفصيل...',
                      hintTextDirection: TextDirection.rtl,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel(text: 'العنوان'),
                  OutlinedButton.icon(
                    onPressed: loading ? null : _pickLocation,
                    icon: Icon(
                      _selectedLat != null
                          ? Icons.location_on_rounded
                          : Icons.map_outlined,
                    ),
                    label: Text(
                      _addressController.text.isNotEmpty
                          ? _addressController.text
                          : 'اختر الموقع على الخريطة',
                    ),
                  ),
                  if (_addressController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${_selectedLat!.toStringAsFixed(4)}, ${_selectedLng!.toStringAsFixed(4)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  _SectionLabel(text: 'طريقة الدفع'),
                  SegmentedButton<PaymentMethod>(
                    segments: const [
                      ButtonSegment(
                        value: PaymentMethod.cash,
                        label: Text('كاش'),
                        icon: Icon(Icons.money_rounded),
                      ),
                      ButtonSegment(
                        value: PaymentMethod.vodafoneCash,
                        label: Text('فودافون كاش'),
                        icon: Icon(Icons.phone_android_rounded),
                      ),
                    ],
                    selected: {_paymentMethod},
                    onSelectionChanged: loading
                        ? null
                        : (v) => setState(() => _paymentMethod = v.first),
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel(text: 'السعر المقترح'),
                  TextFormField(
                    controller: _priceController,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'اكتب السعر';
                      if (double.tryParse(v) == null || double.parse(v) <= 0) {
                        return 'سعر غير صحيح';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: 'مثلاً: 200',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: loading ? null : () => _submitOrder(context),
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('إرسال الطلب'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<MapPickerResult>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          initialLat: _selectedLat,
          initialLng: _selectedLng,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _selectedLat = result.latitude;
        _selectedLng = result.longitude;
        _addressController.text = result.address;
      });
    }
  }

  void _submitOrder(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthVerified) {
      _showSnackBar(context, 'يجب تسجيل الدخول أولاً');
      return;
    }

    final order = OrderModel(
      id: '',
      userId: authState.user.id,
      serviceType: _selectedService,
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      paymentMethod: _paymentMethod,
      userAddress: _addressController.text.trim(),
      userLat: _selectedLat,
      userLng: _selectedLng,
    );

    context.read<OrderCubit>().createOrder(order);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
