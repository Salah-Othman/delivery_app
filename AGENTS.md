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

# Firebase
firebase deploy --only functions   # deploy Cloud Functions
firebase deploy --only firestore   # deploy Firestore rules + indexes
firebase deploy --only storage     # deploy Storage rules
```

## Firebase Setup (One Time)
1. Create project at `console.firebase.google.com` named `eid-wahda`
2. Enable **Phone Auth** in Authentication → Sign-in method
3. Register Android app with package `app_delivery` → download `google-services.json` → place in `android/app/`
4. Run `flutterfire configure` (or manually add iOS/Web config)
5. Deploy functions: `cd functions && npm install && cd .. && firebase deploy --only functions`
6. Seed categories collection from Firestore console or a seed script

## Cloud Functions
`functions/index.js` contains:
- `matchProvider` — auto-assigns nearest/least-loaded provider to new orders
- `updateProviderRating` — recalculates average rating on new review

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
├── core/                  # shared theme, constants, routes, firebase init
├── features/              # feature modules
│   ├── auth/
│   │   ├── screens/       # login_screen, otp_screen
│   │   └── services/      # auth_service (Firebase phone auth)
│   ├── orders/
│   │   ├── screens/       # new_order, order_tracking, order_history
│   │   └── services/      # order_service (Firestore CRUD)
│   ├── services/
│   ├── payments/
│   └── profile/
│       └── screens/       # profile_screen
├── models/                # user, provider, order, review, category

functions/
├── index.js               # Cloud Functions (matchProvider, updateProviderRating)
└── package.json

firestore.rules            # Firestore security rules
storage.rules              # Storage security rules
```

## Key Constraints
- Minimal budget — use Firebase free tier aggressively
- Offline resilience: handle intermittent 3G connectivity
- Cash-first: many users have no bank card
- Mobile-only: no web version for MVP
