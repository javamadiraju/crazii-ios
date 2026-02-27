# Crazii iOS App

This is the iOS version of the Crazii Flutter application.

## Prerequisites

1. **macOS** - iOS development requires a Mac
2. **Xcode 15+** - Install from the App Store
3. **Flutter SDK** - [Install Flutter](https://flutter.dev/docs/get-started/install/macos)
4. **CocoaPods** - Install via `sudo gem install cocoapods`

## Setup Instructions

### 1. Get Flutter Dependencies

```bash
cd /path/to/crazii-ios
flutter pub get
```

### 2. Generate iOS Project Files

If the `ios/Flutter/Generated.xcconfig` doesn't exist:

```bash
flutter create --platforms=ios .
```

Or regenerate Flutter iOS configuration:

```bash
flutter build ios --no-codesign
```

### 3. Install CocoaPods Dependencies

```bash
cd ios
pod install
cd ..
```

### 4. Open in Xcode

```bash
open ios/Runner.xcworkspace
```

### 5. Configure Signing

1. In Xcode, select the `Runner` project
2. Go to **Signing & Capabilities** tab
3. Select your **Team** from the dropdown
4. Update the **Bundle Identifier** if needed (currently: `com.example.freebankingapp`)

### 6. Build and Run

**From Terminal:**
```bash
flutter run -d ios
```

**From Xcode:**
1. Select your target device/simulator
2. Press **Cmd + R** to build and run

## Configuration

### Google Sign-In Setup

1. Get your iOS Client ID from [Google Cloud Console](https://console.cloud.google.com/)
2. Update `ios/Runner/Info.plist`:
   - Replace `YOUR_GOOGLE_CLIENT_ID` with your actual Client ID
   - Add the reversed client ID to URL schemes

### Stripe Setup

The Stripe SDK is configured in `ios/Podfile`. Make sure your Stripe publishable key is set in your Flutter code.

### Push Notifications

1. Enable **Push Notifications** capability in Xcode
2. Configure your APNs key in Firebase/your push service
3. The `AppDelegate.swift` is already configured to handle notifications

## Build for Release

### Archive for App Store

```bash
flutter build ipa
```

Or in Xcode:
1. Select **Product > Archive**
2. Use **Organizer** to distribute

### Ad Hoc / Development Build

```bash
flutter build ios --release
```

## CI / GitHub Actions

Builds run automatically on push/PR to `main` and can be triggered manually:

- **Build iOS** (macOS): `flutter build ios --simulator` (no code signing needed). Artifact `ios-simulator-build` (Runner.app) retained 14 days. Use this app in Xcode’s iOS Simulator.
- **Analyze** (Ubuntu): `flutter analyze` to check for issues.

For a **device** or **App Store** build you need a Development Team and to run `flutter build ios` or `flutter build ipa` locally. Go to the **Actions** tab to download the latest simulator build.

## Troubleshooting

### Pod Install Fails

```bash
cd ios
pod deintegrate
pod cache clean --all
pod install
```

### Xcode Build Errors

1. Clean build folder: **Cmd + Shift + K**
2. Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`
3. Regenerate Flutter files: `flutter clean && flutter pub get`

### Minimum iOS Version

This app requires **iOS 13.0** or later.

## App Structure

```
crazii-ios/
├── lib/                    # Dart source code (shared with Android)
├── assets/                 # Images, fonts, and other assets
├── ios/
│   ├── Runner/             # iOS native code
│   │   ├── AppDelegate.swift          # App lifecycle & notification handling
│   │   ├── NotificationService.swift  # Background notification polling
│   │   ├── Info.plist
│   │   └── Assets.xcassets/
│   ├── Podfile             # CocoaPods dependencies
│   └── Runner.xcworkspace/ # Open this in Xcode
├── pubspec.yaml            # Flutter dependencies
└── README.md
```

## Background Notification Service

The iOS app includes a `NotificationService.swift` that mirrors the Android `NotificationService.java` functionality:

### How It Works

| Feature | Android | iOS |
|---------|---------|-----|
| **Foreground Polling** | Handler with 30s interval | Timer with 30s interval |
| **Background Execution** | Foreground Service | BGTaskScheduler + Background Fetch |
| **API Polling** | OkHttp | URLSession |
| **Local Notifications** | NotificationCompat | UNUserNotificationCenter |
| **User Data Storage** | SharedPreferences | UserDefaults |

### iOS Limitations

Unlike Android's continuous foreground service, iOS has stricter background execution rules:

1. **Foreground**: Timer polls every 30 seconds (same as Android)
2. **Background**: Uses `BGAppRefreshTask` - iOS decides when to run (typically 15+ minutes)
3. **Silent Push**: Can trigger immediate background fetch if you configure APNs

### Key Files

- **`NotificationService.swift`**: Singleton service that:
  - Polls `https://cgmember.com/api/all-user-notifications/{userId}` 
  - Filters for unread market notifications (`is_market=1`, `is_read=0`)
  - Shows native iOS notifications
  - Tracks last seen notification timestamp

- **`AppDelegate.swift`**: Integrates the service with app lifecycle:
  - Starts service on launch
  - Handles foreground/background transitions
  - Processes notification taps via Flutter MethodChannel

### Background Modes in Info.plist

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>              <!-- Background App Refresh -->
    <string>remote-notification</string> <!-- Silent Push Notifications -->
    <string>processing</string>          <!-- BGTaskScheduler -->
</array>

<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.example.freebankingapp.notificationPoll</string>
</array>
```

## Version

- **App Version:** 2.0.0
- **Build Number:** 1
- **Flutter SDK:** >=3.3.4 <4.0.0
- **iOS Deployment Target:** 13.0
