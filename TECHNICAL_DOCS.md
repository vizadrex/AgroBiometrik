
# AgroBiometrik Technical Documentation

## Architecture Overview
AgroBiometrik follows **Clean Architecture** principles, separating the application into three main layers:

1.  **Domain Layer**: Contains Entities (`Animal`, `Embedding`) and Repository Interfaces. This layer is pure Dart and has no dependencies on Flutter or data sources.
2.  **Data Layer**: Contains Models (JSON/DB serialization), Data Sources (`sqflite` implementation), and Repository Implementations.
3.  **Presentation Layer**: Contains UI code (Screens, Widgets) and State Management (BLoC).
4.  **Core Layer**: Contains shared services, including the **AI Engine**.

## AI & Biometrics Engine

### 1. Image Preprocessing
Located in `lib/core/services/ai/image_preprocessing_service.dart`.
-   **Resize**: Images are resized to 224x224 (configurable).
-   **Normalization**: Pixel values are normalized to [0, 1] or [-1, 1] for Float32 inference.

### 2. Embedding Extraction
Located in `lib/core/services/ai/embedding_service.dart`.
-   Uses `tflite_flutter` to run inference on edge devices.
-   Outputs a feature vector (e.g., 128-d Float32List) representing the animal's biometric signature.

### 3. Matching Logic
Located in `lib/core/services/ai/matching_service.dart`.
-   **Euclidean Distance**: Used to compare new embeddings against stored ones.
-   **Dynamic Thresholds**: (Planned) Species-specific thresholds to determining identification vs. new registration.

### 4. Learning & Quality
Located in `lib/core/services/ai/learning_service.dart`.
-   **Active Learning**: System learns from user confirmations.
-   **Dataset Quality**: Checks for outliers and dataset balance.

## Database Schema
The local database (`sqflite`) stores:
-   **Animals**: Core identity data.
-   **Embeddings**: Vector data linked to animals, with versioning.
-   **Captures**: History of detections.

## Future Roadmap
-   [ ] Implement specific TFLite models for Cattle/Swine.
-   [ ] Add Cloud Sync (using SyncRepository contract).
-   [ ] Enable PDF Reporting.
