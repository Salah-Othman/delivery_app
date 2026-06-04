# إيد واحدة (Eid Wahda) — Delivery & Maintenance App

## Project Identity
- **App name**: إيد واحدة (Eid Wahda)
- **Package name**: `app_delivery`
- **Target market**: Abu Qirqas, Minya Governorate, Egypt
- **Purpose**: Home maintenance (سباكة/كهرباء/تكييف) + delivery service
- **Audience**: Egyptian Arabic speakers, mid-to-low-end Android devices, 3G

## Architecture
- **Two Flutter apps**: `app_delivery` (customer) + separate app for providers
- **Backend**: Firebase (Auth, Firestore, Cloud Functions, Storage)
- **Payments**: Cash on delivery + Vodafone Cash
- **Auth**: Phone OTP only (no email/password)
- **Primary language**: Arabic (RTL) — English secondary

## Development Commands
```
flutter pub get              # install dependencies
flutter analyze              # lint check (uses flutter_lints)
flutter test                 # run all tests
flutter run                  # run on connected device
flutter build apk --release  # build Android APK (primary target)
flutter build appbundle      # build for Play Store
```

## Conventions
- Arabic-first: all user-facing strings in Arabic, RTL layout
- Lightweight APK target: <30MB, compress assets
- Test on 3G throttled connection
- Optimize for low-end Android (API 21+)
- No Apple Developer account needed for MVP (iOS launch later)

## Project Structure
```
lib/
├── main.dart              # entrypoint (customer app)
├── providers/             # provider-side app (separate)
├── core/                  # shared theme, constants, localization
├── features/              # feature modules
│   ├── auth/
│   ├── orders/
│   ├── services/
│   └── payments/
└── models/
```

## Key Constraints
- Minimal budget — use Firebase free tier aggressively
- Offline resilience: handle intermittent 3G connectivity
- Cash-first: many users have no bank card
- Mobile-only: no web version for MVP
