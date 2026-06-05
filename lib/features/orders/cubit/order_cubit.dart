import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/order_model.dart';
import '../services/order_service.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderService _orderService;

  OrderCubit({OrderService? orderService})
      : _orderService = orderService ?? OrderService(),
        super(const OrderInitial());

  Future<void> createOrder(OrderModel order) async {
    emit(const OrderLoading());
    try {
      final orderId = await _orderService.createOrder(order);
      emit(OrderCreated(orderId: orderId));
    } catch (e) {
      emit(OrderError(message: _errorMessage(e)));
    }
  }

  void reset() => emit(const OrderInitial());

  String _errorMessage(Object e) {
    final msg = e.toString();
    if (msg.contains('network-request-failed')) {
      return 'مشكلة في الاتصال، حاول مرة أخرى';
    }
    if (msg.contains('permission-denied')) {
      return 'ليس لديك صلاحية للقيام بهذه العملية';
    }
    return 'حدث خطأ أثناء إرسال الطلب، حاول مرة أخرى';
  }
}
