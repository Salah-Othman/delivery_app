class AppConstants {
  AppConstants._();

  static const String appName = 'إيد واحدة';
  static const String appNameEn = 'Eid Wahda';
  static const String packageName = 'app_delivery';

  static const Duration orderTimeout = Duration(minutes: 5);
  static const double defaultCommission = 0.10;
  static const double maxOrderRadiusKm = 10.0;

  static const String firebaseCollectionUsers = 'users';
  static const String firebaseCollectionProviders = 'providers';
  static const String firebaseCollectionOrders = 'orders';
  static const String firebaseCollectionCategories = 'categories';
  static const String firebaseCollectionReviews = 'reviews';
}
