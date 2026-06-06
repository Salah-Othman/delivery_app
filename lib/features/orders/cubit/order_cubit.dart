import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/app_exception.dart';
import '../../../core/error_utils.dart';
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
    } catch (e, s) {
      logError(e, s, context: 'OrderCubit.createOrder');
      emit(OrderError(message: firestoreErrorMessage(e)));
    }
  }

  void reset() => emit(const OrderInitial());
}
