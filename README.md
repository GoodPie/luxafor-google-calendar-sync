Collecting workspace information# Luxafor Calendar Sync

A Flutter desktop application for macOS that syncs your Google Calendar status with your Luxafor flag. When you're in a meeting, the flag turns red. When you're free, it turns green.

## Features

- Google Calendar integration to check your current meeting status
- Luxafor flag control via the official Webhook API
- Customizable sync interval (10-300 seconds)
- Simple, clean UI with status indicators
- Automatic background syncing

## Setup Instructions

### Prerequisites

- macOS (10.14 or later)
- Flutter SDK installed
- Luxafor Flag device
- Google account with Calendar access
- Luxafor app installed (to get your Luxafor User ID)

### Step 1: Google Cloud Setup

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project
3. Enable the Google Calendar API
4. Create OAuth 2.0 credentials (Desktop application type)
5. Download the credentials JSON file
6. Place the credentials file in the assets directory as `google_calendar_credentials.json`

### Step 2: Luxafor User ID

1. Open the Luxafor application on your macOS
2. Go to the "Webhook" tab
3. Your Luxafor User ID will be displayed there
4. Copy this ID to use in the app

### Step 3: Building and Running the App

```bash
# Clone the repository
git clone https://github.com/yourusername/luxafor_calendar_sync.git
cd luxafor_calendar_sync

# Get dependencies
flutter pub get

# Run the app
flutter run -d macos
```

### Step 4: Using the App

1. Launch the app
2. Click "Sign In" to authenticate with Google Calendar
3. Enter your Luxafor User ID in the settings
4. Toggle the sync switch to start monitoring
5. Your Luxafor flag will turn red during meetings and green when you're free

## Project Structure

```
lib/
├── main.dart               # App entry point
├── screens/
│   └── home_screen.dart    # Main screen UI
├── services/
│   ├── auth_service.dart   # Google authentication
│   ├── calendar_service.dart # Calendar API interactions
│   ├── luxafor_service.dart # Luxafor API interactions
│   └── storage_service.dart # Secure credential storage
└── widgets/
    ├── status_card.dart    # Current status display
    ├── settings_card.dart  # Authentication and user ID settings
    └── sync_control_card.dart # Sync controls and interval settings
```

## Troubleshooting

- **Authentication Issues**: Ensure your Google Cloud project is correctly configured with the right scopes and redirect URIs.
- **Luxafor Not Responding**: Check that your Luxafor User ID is correct and that the device is properly connected.
- **Permission Errors**: The first time you sign in, you may need to grant explicit permission to access your calendar.

## Privacy

This application runs locally on your machine and only communicates with Google Calendar API and Luxafor API services. Your credentials are stored securely using the macOS Keychain.