class UserModel {
  final String id;
  final String phone;
  final String? name;
  final String? address;
  final double? lat;
  final double? lng;
  final int orderCount;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.phone,
    this.name,
    this.address,
    this.lat,
    this.lng,
    this.orderCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'phone': phone,
        'name': name,
        'address': address,
        'lat': lat,
        'lng': lng,
        'orderCount': orderCount,
        'createdAt': createdAt,
      };

  factory UserModel.fromMap(Map<String, dynamic> map, String id) => UserModel(
        id: id,
        phone: map['phone'] as String,
        name: map['name'] as String?,
        address: map['address'] as String?,
        lat: (map['lat'] as num?)?.toDouble(),
        lng: (map['lng'] as num?)?.toDouble(),
        orderCount: (map['orderCount'] as num?)?.toInt() ?? 0,
        createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      );

  UserModel copyWith({
    String? name,
    String? address,
    double? lat,
    double? lng,
    int? orderCount,
  }) =>
      UserModel(
        id: id,
        phone: phone,
        name: name ?? this.name,
        address: address ?? this.address,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        orderCount: orderCount ?? this.orderCount,
        createdAt: createdAt,
      );
}
