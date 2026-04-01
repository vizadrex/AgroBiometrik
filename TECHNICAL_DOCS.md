# Documentación Técnica de AgroBiometrik

## Visión General de la Arquitectura
AgroBiometrik está construido siguiendo los principios de **Clean Architecture** (Arquitectura Limpia). Esto nos ayuda a mantener todo organizado y que pueda crecer a futuro, dividiendo la aplicación en cuatro grandes capas:

1.  **Capa de Dominio (Domain Layer)**: Aquí viven nuestras entidades conceptuales más importantes (como `Animal` y `Embedding`) y las interfaces de los repositorios. Es código Dart puro y duro, sin dependencias complicadas de Flutter ni detalles sobre de dónde vienen los datos.
2.  **Capa de Datos (Data Layer)**: Esta es la responsable de la información. Aquí definimos los modelos (para leer y escribir JSON o hablar con la base de datos), las fuentes de datos (nuestra implementación real de `sqflite`) y las concreciones de los repositorios.
3.  **Capa de Presentación (Presentation Layer)**: Todo lo que el usuario ve y con lo que interactúa. Incluye nuestras pantallas, los widgets y toda la lógica para gestionar el estado utilizando BLoC.
4.  **Capa Central (Core Layer)**: Incluye los servicios base, compartidos por toda la aplicación, destacando de sobremanera el **Motor de Inteligencia Artificial**.

## Motor Biométrico y de IA
Este es el cerebro detrás de la identificación. Así es como logramos reconocer a los animales:

### 1. Preprocesamiento de Imágenes
Encuéntralo en `lib/core/services/ai/image_preprocessing_service.dart`.
-   **Redimensionamiento**: Ajustamos todas las fotos a un tamaño estándar manejable de 224x224 píxeles (configurable según el modelo).
-   **Normalización**: Adaptamos los valores matemáticos de los píxeles a rangos de [0, 1] o [-1, 1], preparándolos óptimamente para el proceso de inferencia en Float32.

### 2. Extracción de Vectores (Embeddings)
Encuéntralo en `lib/core/services/ai/embedding_service.dart`.
-   Utilizamos la librería `tflite_flutter` para ejecutar nuestro modelo de aprendizaje profundo directamente en el dispositivo móvil (Edge AI), sin mandar nada a servidores externos.
-   El resultado de este proceso es un vector de características (por ejemplo, una lista de 128 dimensiones de tipo Float32List) que funciona en la práctica como la "huella digital" del animal.

### 3. Lógica de Emparejamiento
Encuéntralo en `lib/core/services/ai/matching_service.dart`.
-   **Distancia Euclidiana**: Es el cálculo matemático que usamos para comparar la "huella digital" de la foto tomada con todas las huellas que ya tenemos guardadas.
-   **Umbrales Dinámicos**: (Actualmente en planes). Estamos preparando el sistema para poder ajustar la exigencia de similitud por cada especie; para decidir con mayor precisión si el animal es el mismo o si tenemos que abrir un nuevo registro.

### 4. Aprendizaje y Mejora Continua
Encuéntralo en `lib/core/services/ai/learning_service.dart`.
-   **Aprendizaje Activo (Active Learning)**: El sistema nunca deja de aprender; se vuelve más hábil cada vez que el usuario confirma que una identificación que sugirió es correcta.
-   **Calidad del Dataset**: Analizamos silenciosamente nuestro propio banco de datos de reconocimiento para limpiar anomalías o balancearlo, manteniendo siempre eficiente al modelo.

## Esquema de Base de Datos
Toda la valiosa información recolectada se guarda de forma segura en la base de datos local del móvil (`sqflite`), la cual organiza los datos en:
-   **Animales**: El núcleo de las identidades guardadas.
-   **Embeddings**: Las representaciones matemáticas (vectores) que identifican a cada animal, implementadas con un sistema de versiones.
-   **Capturas**: El registro histórico de todas las veces y lugares donde se ha reconocido y detectado a los animales.

## Próximos Pasos (Roadmap)
Tenemos en la mira las siguientes mejoras a futuro:
-   [ ] Implementar modelos especializados de TFLite enfocados exclusivamente en Ganado Vacuno y Porcino.
-   [ ] Añadir la función de Sincronización en la Nube (cumpliendo con el contrato `SyncRepository`).
-   [ ] Habilitar la exportación detallada de reportes estadísticos en formato PDF.
