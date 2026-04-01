
# AgroBiometrik

**AgroBiometrik** is a professional, offline-first mobile application for biometric animal identification using Edge AI.

## Features
-   **AI-Powered Identification**: Identifies animals using facial/body embeddings without tags.
-   **Local Database**: Secure, encrypted SQLite storage for thousands of records.
-   **Offline First**: Works completely without internet in remote areas.
-   **Dashboard Analytics**: Visual insights into population statistics.

## Getting Started

### Prerequisites
-   Flutter SDK (Latest Stable)
-   Android Studio / VS Code

### Installation
1.  Clone the repository.
2.  Run `flutter pub get`.
3.  Connect a device or emulator.
4.  Run `flutter run`.

### Setup AI Model
Place your TFLite model in `assets/models/reid_model.tflite` and update `lib/core/services/ai/embedding_service.dart`.

## Architecture
This project uses Clean Architecture + BLoC.

## License
Proprietary / Enterprise.
