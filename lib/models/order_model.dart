enum OrderStatus {
  pending,
  accepted,
  inProgress,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'قيد الانتظار';
      case OrderStatus.accepted:
        return 'تم القبول';
      case OrderStatus.inProgress:
        return 'جارٍ العمل';
      case OrderStatus.completed:
        return 'تم الانتهاء';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

enum PaymentMethod {
  cash,
  vodafoneCash;

  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'كاش';
      case PaymentMethod.vodafoneCash:
        return 'فودافون كاش';
    }
  }

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}

class OrderModel {
  final String id;
  final String userId;
  final String? providerId;
  final String serviceType;
  final String description;
  final OrderStatus status;
  final double price;
  final PaymentMethod paymentMethod;
  final String? userAddress;
  final double? userLat;
  final double? userLng;
  final DateTime createdAt;
  final DateTime? completedAt;

  OrderModel({
    required this.id,
    required this.userId,
    this.providerId,
    required this.serviceType,
    required this.description,
    this.status = OrderStatus.pending,
    required this.price,
    this.paymentMethod = PaymentMethod.cash,
    this.userAddress,
    this.userLat,
    this.userLng,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'providerId': providerId,
        'serviceType': serviceType,
        'description': description,
        'status': status.name,
        'price': price,
        'paymentMethod': paymentMethod.name,
        'userAddress': userAddress,
        'userLat': userLat,
        'userLng': userLng,
        'createdAt': createdAt,
        'completedAt': completedAt,
      };

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) =>
      OrderModel(
        id: id,
        userId: map['userId'] as String,
        providerId: map['providerId'] as String?,
        serviceType: map['serviceType'] as String,
        description: map['description'] as String,
        status: OrderStatus.fromString(map['status'] as String? ?? 'pending'),
        price: (map['price'] as num?)?.toDouble() ?? 0,
        paymentMethod:
            PaymentMethod.fromString(map['paymentMethod'] as String? ?? 'cash'),
        userAddress: map['userAddress'] as String?,
        userLat: (map['userLat'] as num?)?.toDouble(),
        userLng: (map['userLng'] as num?)?.toDouble(),
        createdAt: map['createdAt'] != null
            ? (map['createdAt'] is DateTime
                ? map['createdAt'] as DateTime
                : (map['createdAt'] as dynamic).toDate())
            : DateTime.now(),
        completedAt: map['completedAt'] != null
            ? (map['completedAt'] is DateTime
                ? map['completedAt'] as DateTime
                : (map['completedAt'] as dynamic).toDate())
            : null,
      );
}
