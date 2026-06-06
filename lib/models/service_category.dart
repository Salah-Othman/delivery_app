class ServiceCategory {
  final String name;
  final String icon;
  final String collectionId;

  const ServiceCategory(this.name, this.icon, [this.collectionId = '']);
}

class AppCategories {
  AppCategories._();

  static const categories = [
    ServiceCategory('تكييف', 'ac_unit'),
    ServiceCategory('سباكة', 'water_drop'),
    ServiceCategory('كهرباء', 'bolt'),
    ServiceCategory('نجارة', 'handyman'),
    ServiceCategory('دهان', 'format_paint'),
    ServiceCategory('توصيل', 'delivery_dining'),
  ];
}
