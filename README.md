# daim

daim is a Flutter loyalty app for cafes and restaurants. Customers
discover places, place orders, collect points and badges, and unlock
membership tiers. Staff use the same app in employee mode to scan a
customer's QR code and record their order.

## Features

- Phone verification on sign-up
- Customer and employee modes
- Restaurant list with Google Maps locations
- Menu browsing and order flow with review step
- QR code generation for customers and scanner for employees
- Points, rewards, badges and membership tiers (silver / gold / diamond / premium)
- Campaigns and notifications via Firebase Cloud Messaging
- Turkish and English localization

## Built With

- Flutter (Dart SDK ^3.9)
- Firebase: Core, Firestore, App Check, Crashlytics, Remote Config, Messaging
- Provider for state management
- google_maps_flutter, geolocator, permission_handler
- mobile_scanner, qr_flutter
- flutter_local_notifications, url_launcher, smooth_page_indicator

## Getting Started

You'll need the Flutter SDK installed. Then:

```
flutter pub get
flutter run
```

## Configuration

The app uses Firebase, Google Maps and FCM. You'll need your own
Firebase project and config files (`google-services.json`,
`GoogleService-Info.plist`, and a generated `firebase_options.dart`),
plus a Google Maps API key configured in the Android and iOS native
projects.
