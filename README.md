# إيد واحدة (Eid Wahda)

تطبيق سوبر أندرويد يقدم خدمات الصيانة المنزلية والتوصيل في أبو قرقاص، المنيا.

## المميزات
- طلب خدمات الصيانة (سباكة، كهرباء، تكييف، نجارة، دهان)
- خدمة التوصيل من المحلات
- متابعة الطلب في الوقت الفعلي
- دفع كاش أو فودافون كاش
- تقييم مقدم الخدمة

## التقنيات
- **Flutter** (Android first, iOS later)
- **Firebase** (Auth, Firestore, Functions, Storage, Messaging, Crashlytics)
- **Flutter BLoC** for state management

## التطوير
```bash
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --release
```

## هيكل المشروع
```
lib/
├── main.dart
├── core/          # theme, constants, routes, error_utils, app_exception
├── features/      # auth, orders, notifications, services, profile
├── models/        # user, provider, order, review, category
└── shared/        # widgets
```
