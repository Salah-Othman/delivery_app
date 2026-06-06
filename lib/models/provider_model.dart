class ProviderModel {
  final String id;
  final String email;
  final String phone;
  final String name;
  final List<String> services;
  final bool available;
  final double? lat;
  final double? lng;
  final double rating;
  final int totalOrders;
  final double commission;
  final double totalEarnings;
  final DateTime createdAt;

  ProviderModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.name,
    this.services = const [],
    this.available = true,
    this.lat,
    this.lng,
    this.rating = 0,
    this.totalOrders = 0,
    this.commission = 0.10,
    this.totalEarnings = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'phone': phone,
        'name': name,
        'services': services,
        'available': available,
        'lat': lat,
        'lng': lng,
        'rating': rating,
        'totalOrders': totalOrders,
        'commission': commission,
        'totalEarnings': totalEarnings,
        'createdAt': createdAt,
      };

  factory ProviderModel.fromMap(Map<String, dynamic> map, String id) =>
      ProviderModel(
        id: id,
        email: map['email'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        name: map['name'] as String? ?? '',
        services: List<String>.from(map['services'] ?? []),
        available: map['available'] as bool? ?? true,
        lat: (map['lat'] as num?)?.toDouble(),
        lng: (map['lng'] as num?)?.toDouble(),
        rating: (map['rating'] as num?)?.toDouble() ?? 0,
        totalOrders: (map['totalOrders'] as num?)?.toInt() ?? 0,
        commission: (map['commission'] as num?)?.toDouble() ?? 0.10,
        totalEarnings: (map['totalEarnings'] as num?)?.toDouble() ?? 0,
        createdAt: map['createdAt'] != null
            ? (map['createdAt'] is DateTime
                ? map['createdAt'] as DateTime
                : (map['createdAt'] as dynamic).toDate())
            : DateTime.now(),
      );

  ProviderModel copyWith({
    String? name,
    bool? available,
    double? lat,
    double? lng,
    double? rating,
    int? totalOrders,
    double? totalEarnings,
  }) =>
      ProviderModel(
        id: id,
        email: email,
        phone: phone,
        name: name ?? this.name,
        services: services,
        available: available ?? this.available,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        rating: rating ?? this.rating,
        totalOrders: totalOrders ?? this.totalOrders,
        commission: commission,
        totalEarnings: totalEarnings ?? this.totalEarnings,
        createdAt: createdAt,
      );
}
