class CategoryModel {
  final String id;
  final String nameAr;
  final String icon;
  final int orderCount;

  CategoryModel({
    required this.id,
    required this.nameAr,
    required this.icon,
    this.orderCount = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nameAr': nameAr,
        'icon': icon,
        'orderCount': orderCount,
      };

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) =>
      CategoryModel(
        id: id,
        nameAr: map['nameAr'] as String,
        icon: map['icon'] as String? ?? 'handyman',
        orderCount: (map['orderCount'] as num?)?.toInt() ?? 0,
      );
}
