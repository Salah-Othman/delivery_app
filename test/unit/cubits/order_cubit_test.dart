import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app_delivery/features/orders/cubit/order_cubit.dart';
import 'package:app_delivery/features/orders/cubit/order_state.dart';
import 'package:app_delivery/features/orders/services/order_service.dart';
import 'package:app_delivery/models/order_model.dart';
import '../../helpers/mocks.dart';

class MockOrderService extends Mock implements OrderService {}

void main() {
  late MockOrderService mockOrderService;
  late OrderCubit cubit;

  setUpAll(() {
    registerFallbackValue(OrderModel(
      id: '',
      userId: '',
      serviceType: '',
      description: '',
      price: 0,
    ));
  });

  setUp(() {
    mockOrderService = MockOrderService();
    cubit = OrderCubit(orderService: mockOrderService);
  });

  tearDown(() {
    cubit.close();
  });

  group('initial state', () {
    test('starts as OrderInitial', () {
      expect(cubit.state, const OrderInitial());
    });
  });

  group('createOrder', () {
    test('emits OrderCreated on success', () async {
      when(() => mockOrderService.createOrder(any()))
          .thenAnswer((_) async => 'order_1');

      final emitted = <Type>[];
      cubit.stream.listen((s) => emitted.add(s.runtimeType));

      cubit.createOrder(OrderModel(
        id: '',
        userId: 'u1',
        serviceType: 'c1',
        description: 'test',
        userAddress: 'addr',
        userLat: 30.0,
        userLng: 31.0,
        paymentMethod: PaymentMethod.cash,
        price: 0,
      ));
      await Future.delayed(Duration.zero);

      expect(emitted, [OrderLoading, OrderCreated]);
    });

    test('emits OrderError on failure', () async {
      when(() => mockOrderService.createOrder(any()))
          .thenThrow(Exception('network-request-failed'));

      final emitted = <Type>[];
      cubit.stream.listen((s) => emitted.add(s.runtimeType));

      cubit.createOrder(OrderModel(
        id: '',
        userId: 'u1',
        serviceType: 'c1',
        description: 'test',
        userAddress: 'addr',
        userLat: 30.0,
        userLng: 31.0,
        paymentMethod: PaymentMethod.cash,
        price: 0,
      ));
      await Future.delayed(Duration.zero);

      expect(emitted, [OrderLoading, OrderError]);
    });
  });

  group('reset', () {
    test('emits OrderInitial', () {
      cubit.reset();
      expect(cubit.state, const OrderInitial());
    });
  });
}
