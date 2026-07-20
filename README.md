# 🐄 AgroBiometrik — Identificación biométrica de animales con IA (offline)

**AgroBiometrik** es una aplicación móvil en **Flutter** que identifica animales de granja **por su apariencia física**, usando la cámara del teléfono y machine learning **directamente en el dispositivo** (Edge AI con TensorFlow Lite). Está pensada para el registro ganadero en zonas rurales: funciona **100% sin internet** y sin necesidad de marcas o aretes físicos.

## Capturas

![Pantalla principal](image.png)
![Identificación con cámara](image-1.png)
![Inventario y dashboard](image-2.png)

## Características principales

- 📷 **Registro con fotos:** capturas al animal, la app preprocesa la imagen y extrae su "huella" visual (embedding).
- 🧠 **Identificación por similitud:** apuntas la cámara y la app te dice **cuál de tus animales registrados es** — o lo marca como desconocido si no supera el umbral de confianza.
- 📋 **Inventario local:** nombre, especie, raza, fecha y notas de cada animal en SQLite; consulta rápida incluso con miles de registros.
- 📊 **Panel de analíticas** con estadísticas del hato, gráficos (fl_chart) y **exportación a PDF**.
- 🔍 **Control de calidad del dataset:** un servicio evalúa si las fotos registradas son suficientemente buenas y variadas para identificar con confianza.

## ¿Cómo funciona la IA?

1. **MobileNetV2** (TensorFlow Lite, incluido en `assets/models/`) convierte cada foto en un **vector de características (embedding)**.
2. Los embeddings se guardan en SQLite junto con los datos del animal.
3. Para identificar, se calcula la **distancia euclidiana** entre el embedding de la foto nueva y todos los registrados; los **5 más cercanos "votan"** (k-NN por mayoría) y un umbral de distancia rechaza a los desconocidos.

Todo ocurre en el teléfono: no hay servidor, no hay API, no se necesita señal.

> 💡 El modelo es intercambiable: si entrenas un modelo de re-identificación propio, colócalo en `assets/models/` y actualiza la ruta en `lib/core/services/ai/model_loader_service.dart`.

## Arquitectura

El proyecto sigue **Clean Architecture** con **BLoC** para el estado:

```
lib/
├── core/
│   ├── services/
│   │   ├── ai/                  # Embeddings, matching, identificación,
│   │   │                        # preprocesamiento y calidad de dataset
│   │   ├── camera_service.dart
│   │   └── service_locator.dart # Inyección de dependencias (get_it)
│   ├── error/                   # Manejo global de errores + observer de BLoC
│   └── theme.dart
├── data/                        # sqflite, modelos, repositorios (implementación)
├── domain/                      # Entidades y contratos (independiente de Flutter)
└── presentation/                # Pantallas: cámara, inventario, dashboard
```

## Cómo ejecutarlo

```bash
flutter pub get
flutter run
```

Requisitos: Flutter SDK estable y un dispositivo o emulador **Android** con cámara.

## Tecnologías

- **Flutter / Dart** · `flutter_bloc` · `get_it` · `equatable` · `dartz`
- **tflite_flutter** + MobileNetV2 (visión por computadora on-device)
- **sqflite** · **camera** · **fl_chart** · **pdf**

## Lo que aprendí con este proyecto

- Ejecutar redes neuronales **en el teléfono**: preprocesar imágenes al formato del modelo y usar la salida como embedding en lugar de clasificación directa.
- Que un sistema de identificación no es solo el modelo: el umbral de rechazo, la votación por mayoría y la **calidad del dataset** importan tanto como la red.
- Aplicar Clean Architecture de verdad en Flutter, con dominio separado de datos y presentación.
