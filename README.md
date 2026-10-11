# Interactive Storytelling Platform

**A cross-platform space for shared stories and conversations.**

Interactive Storytelling Platform is a Flutter application for bringing people together in topic-based rooms. Users can create a profile, discover rooms by category, and take part in live conversations. Firebase provides the project's cloud data and file storage, with a small Cloud Functions service for web image requests.

> This repository contains an evolving project build. The overview below describes the features and integrations present in the current source.

## Product overview

The platform is organized around themed conversation rooms. A user can create a profile, browse available topics, start a room, and follow its messages as they arrive. The interface also includes a chatbot prototype and profile navigation for related areas of the app.

### Current capabilities

- Profile creation with contact and personal details, plus profile photo upload.
- Profile lookup and sign-in screen.
- Topic-based room discovery across five categories:
  - Emotional Support
  - Information Sharing
  - Coping Strategies
  - Social Connection
  - Empowerment
- Room creation with a title and selected category.
- Live room message feed backed by Cloud Firestore.
- Chatbot interface prototype.
- Flutter targets for web, Android, iOS, Windows, macOS, and Linux.

## Technology

| Layer | Implementation |
| --- | --- |
| Application | Flutter, Dart, Material UI |
| User and room data | Cloud Firestore |
| Profile images | Firebase Storage |
| Server integration | Firebase Cloud Functions for Node.js 18 |
| Supporting packages | `intl`, `email_validator`, `file_picker`, `image_picker`, `path_provider`, `http` |

## Architecture

The client is a Flutter application. Screens and shared form components live in `Interactive Storytelling Platform/lib/components/`, while `lib/main.dart` initializes Firebase and starts the login flow.

The client currently communicates with Firebase directly:

```text
Flutter application
  ├── Cloud Firestore ── profiles, rooms, room messages
  ├── Firebase Storage ─ profile images
  └── Cloud Functions ── HTTP image proxy for web clients
```

Room messages are stored under `rooms/{roomId}/messages` and displayed through a Firestore stream. Room discovery filters the `rooms` collection by category. Profile images are uploaded to Firebase Storage, with profile fields saved in Firestore.

## Project structure

```text
.
├── README.md
├── LICENSE
├── Interactive Storytelling Platform/
│   ├── lib/              # Flutter app, screens, and shared components
│   ├── assets/           # Images and fonts
│   ├── functions/        # Firebase Cloud Functions
│   ├── test/             # Flutter test sources
│   ├── firebase.json     # Firebase deployment configuration
│   ├── firestore.rules   # Firestore security rules
│   └── android/, ios/, web/, windows/, macos/, linux/
└── Project documentation PDFs
```

## Getting started

### Requirements

- Flutter SDK and Dart compatible with the constraint in `pubspec.yaml` (`>=2.17.5 <3.0.0`).
- The platform toolchain for your target (for example, Chrome for web or Android Studio for Android).
- A Firebase project configured for the services used by the app.
- Node.js 18 and npm to run or deploy Cloud Functions.

### Run the app

From the repository root:

```sh
cd "Interactive Storytelling Platform"
flutter pub get
flutter run -d chrome
```

To run on another connected device, see available targets with `flutter devices` and pass the desired device ID to `flutter run`.

### Configure Firebase

Firebase options are currently defined in `lib/main.dart`. For a separate Firebase project, configure platform credentials for that project (FlutterFire CLI is the recommended route) and update the app initialization accordingly. Enable the Firebase services you intend to use and review the database and Storage security rules before connecting real users. The checked-in Firestore and Realtime Database rules currently deny client access.

### Run the Cloud Function emulator

From the Flutter project directory:

```sh
cd functions
npm install
npm run serve
```

The Firebase CLI and a configured Firebase project are required. To deploy after reviewing the target project and function configuration:

```sh
npm run deploy
```

## Implementation status

The repository is an active prototype, and several integrations need follow-up before a production deployment:

- Registration currently writes passwords to Firestore, and the login screen checks those values directly. Replace this flow with Firebase Authentication before handling real accounts.
- Room creation and message sending currently use placeholder user identity values.
- The chatbot contains a placeholder API key and a legacy API endpoint; the current screen is not a configured chatbot service.
- Password recovery and the standalone Chat screen are UI placeholders.
- The profile image proxy URL is a placeholder and must be set to a deployed function URL if the proxy is used.
- Firestore and Realtime Database rules currently deny client reads and writes. Configure access rules for the intended data model before exercising Firebase-backed flows.
- The included widget test is Flutter's starter counter test and does not cover the app's features.

## Development commands

Run from `Interactive Storytelling Platform/`:

```sh
flutter analyze
flutter test
flutter build web
```

## License

See [`LICENSE`](LICENSE) for license details.
