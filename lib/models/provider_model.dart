class ProviderModel {
  final String id;
  final String phone;
  final String name;
  final List<String> services;
  final bool available;
  final double? lat;
  final double? lng;
  final double rating;
  final int totalOrders;
  final double commission;
  final DateTime createdAt;

  ProviderModel({
    required this.id,
    required this.phone,
    required this.name,
    this.services = const [],
    this.available = true,
    this.lat,
    this.lng,
    this.rating = 0,
    this.totalOrders = 0,
    this.commission = 0.10,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'phone': phone,
        'name': name,
        'services': services,
        'available': available,
        'lat': lat,
        'lng': lng,
        'rating': rating,
        'totalOrders': totalOrders,
        'commission': commission,
        'createdAt': createdAt,
      };

  factory ProviderModel.fromMap(Map<String, dynamic> map, String id) =>
      ProviderModel(
        id: id,
        phone: map['phone'] as String,
        name: map['name'] as String,
        services: List<String>.from(map['services'] ?? []),
        available: map['available'] as bool? ?? true,
        lat: (map['lat'] as num?)?.toDouble(),
        lng: (map['lng'] as num?)?.toDouble(),
        rating: (map['rating'] as num?)?.toDouble() ?? 0,
        totalOrders: (map['totalOrders'] as num?)?.toInt() ?? 0,
        commission: (map['commission'] as num?)?.toDouble() ?? 0.10,
        createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      );

  ProviderModel copyWith({
    bool? available,
    double? lat,
    double? lng,
    double? rating,
    int? totalOrders,
  }) =>
      ProviderModel(
        id: id,
        phone: phone,
        name: name,
        services: services,
        available: available ?? this.available,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        rating: rating ?? this.rating,
        totalOrders: totalOrders ?? this.totalOrders,
        commission: commission,
        createdAt: createdAt,
      );
}
