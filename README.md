# GitHub Sidekick - Setup Guide

A beautiful iOS 26-inspired GitHub companion app built with Flutter. Track your contributions, monitor streaks, and visualize your coding activity with a stunning liquid glass aesthetic.

## Prerequisites

Before you begin, ensure you have the following installed:
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio or Xcode (for iOS development)
- Git
- A GitHub account

## Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/github_sidekick.git
cd github_sidekick
```

## Step 2: Install Dependencies

```bash
flutter pub get
```

This will install all the required packages listed in `pubspec.yaml`.

## Step 3: GitHub OAuth App Setup

You need to create a GitHub OAuth App to enable authentication:

1. Go to [GitHub Settings > Developer Settings > OAuth Apps](https://github.com/settings/developers)
2. Click "New OAuth App"
3. Fill in the details:
   - **Application name**: GitHub Sidekick (or whatever you want)
   - **Homepage URL**: `https://yourdomain.com` (or use `http://localhost` for testing)
   - **Authorization callback URL**: `codecompanion://callback`
4. Click "Register application"
5. You'll get a **Client ID** - save this
6. Click "Generate a new client secret" and save the **Client Secret**

## Step 4: Configure Environment Variables

Create a `.env` file in the root directory of the project:

```bash
touch .env
```

Add your GitHub OAuth credentials to the `.env` file:

```env
GITHUB_CLIENT_ID=your_client_id_here
GITHUB_CLIENT_SECRET=your_client_secret_here
GITHUB_REDIRECT_URI=codecompanion://callback
```

**IMPORTANT**: Never commit the `.env` file to version control! It's already in `.gitignore`.

## Step 5: Platform-Specific Setup

### iOS Setup

1. Open `ios/Runner/Info.plist` and add the URL scheme:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.yourcompany.githubsidekick</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>codecompanion</string>
        </array>
    </dict>
</array>
```

2. Update the bundle identifier in Xcode:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select the Runner target
   - Change the Bundle Identifier to something unique (e.g., `com.yourcompany.githubsidekick`)

### Android Setup

1. Open `android/app/src/main/AndroidManifest.xml` and add the intent filter inside the `<activity>` tag:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="codecompanion"
        android:host="callback" />
</intent-filter>
```

2. Update the application ID in `android/app/build.gradle`:

```gradle
defaultConfig {
    applicationId "com.yourcompany.githubsidekick"
    // ... rest of config
}
```

## Step 6: Update GitHub OAuth Callback

Make sure your GitHub OAuth App's callback URL matches what you configured:
- Go back to your GitHub OAuth App settings
- Verify the callback URL is: `codecompanion://callback`

## Step 7: Run the App

### For iOS:
```bash
flutter run -d ios
```

### For Android:
```bash
flutter run -d android
```

### For Web (not recommended for OAuth):
```bash
flutter run -d chrome
```

## Project Structure

```
lib/
├── core/
│   ├── constants/          # API constants, app constants
│   ├── theme/             # iOS 26 liquid glass theme
│   └── utils/             # Utility functions (date utils, etc.)
├── data/
│   ├── models/            # Data models (UserModel, etc.)
│   ├── repositories/      # Data repositories (auth, github)
│   └── services/          # API services, storage service
├── presentation/
│   ├── screens/           # All app screens
│   │   ├── auth/         # Login screen
│   │   ├── home/         # Home screen with stats
│   │   ├── contributions/ # Contribution detail screen
│   │   ├── profile/      # Profile screen
│   │   ├── settings/     # Settings screen
│   │   └── stats/        # Stats screen
│   └── widgets/          # Reusable widgets (glass cards, contribution grid)
├── providers/            # Riverpod state management
├── app.dart             # Main app widget
└── main.dart            # Entry point
```

## Key Features

- **GitHub OAuth Authentication** - Secure login with your GitHub account
- **Contribution Tracking** - Visualize your GitHub activity with a contribution grid
- **Streak Monitoring** - Track your current and longest coding streaks
- **Repository Stats** - See your most active repositories
- **iOS 26 Liquid Glass UI** - Beautiful glassmorphism design
- **Dark Mode Support** - Automatic theme switching

## Troubleshooting

### OAuth not working?
1. Double-check your `.env` file has the correct credentials
2. Verify the callback URL in GitHub OAuth settings matches `codecompanion://callback`
3. Make sure you've added the URL scheme to iOS/Android manifests
4. Try running `flutter clean` and `flutter pub get`

### Contributions not showing?
1. The app fetches commits from the last 400 days
2. Make sure you have commits in public or private repos (app has `repo` scope)
3. Check the debug console for any API errors
4. Verify your GitHub token has the correct permissions

### Build errors?
1. Run `flutter clean`
2. Run `flutter pub get`
3. Delete `ios/Podfile.lock` and run `cd ios && pod install`
4. Make sure Flutter SDK is up to date: `flutter upgrade`

### Deep linking not working?
1. For iOS: Make sure you've added the URL scheme in `Info.plist`
2. For Android: Verify the intent filter is in `AndroidManifest.xml`
3. Test the deep link manually: `adb shell am start -a android.intent.action.VIEW -d "codecompanion://callback?code=test"`

## Dependencies

Main packages used:
- `flutter_riverpod` - State management
- `dio` - HTTP client
- `flutter_secure_storage` - Secure token storage
- `app_links` - Deep linking
- `cached_network_image` - Image caching
- `intl` - Date formatting
- `adaptive_platform_ui` - iOS 26 components
- `flutter_dotenv` - Environment variables

## Contributing

Feel free to submit issues and pull requests!

## License

MIT License - feel free to use this project however you want.

---

**Need help?** Open an issue on GitHub or check the troubleshooting section above.