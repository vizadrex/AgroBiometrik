import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import 'package:agrobiometrik/core/services/camera_service.dart';
import 'package:agrobiometrik/core/services/service_locator.dart';
import 'package:agrobiometrik/core/services/permission_service.dart';
import 'package:agrobiometrik/core/services/ai/embedding_service.dart';
import 'package:agrobiometrik/core/services/ai/identification_service.dart';
import 'package:agrobiometrik/core/services/ai/matching_service.dart';
import 'package:agrobiometrik/data/models/embedding_model.dart';
import 'package:agrobiometrik/data/datasources/animal_local_data_source.dart';

import 'package:agrobiometrik/core/services/ai/model_loader_service.dart';
import 'package:agrobiometrik/domain/repositories/animal_repository.dart';
import 'package:agrobiometrik/domain/entities/animal.dart';
import 'package:uuid/uuid.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CameraService _cameraService = CameraService();
  final PermissionService _permissionService = sl<PermissionService>();
  final EmbeddingService _embeddingService = sl<EmbeddingService>();
  final IdentificationService _idService = sl<IdentificationService>();
  final AnimalRepository _animalRepository = sl<AnimalRepository>();
  final AnimalLocalDataSource _dataSource = sl<AnimalLocalDataSource>();

  bool _isInitialized = false;
  bool _isAnalyzing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  Future<void> _loadModel() async {
    await _embeddingService.loadModel(ModelLoaderService.defaultModelPath);
  }

  Future<void> _captureAndAnalyze() async {
    if (_isAnalyzing) return;

    setState(() => _isAnalyzing = true);

    try {
      final file = await _cameraService.takePicture();
      if (file != null) {
        final bytes = await file.readAsBytes();
        final image = img.decodeImage(bytes);

        if (image != null) {
          final embeddingVector = await _embeddingService.extractEmbedding(
            image,
          );
          final result = await _idService.identifyAnimal(embeddingVector);

          if (mounted) {
            _handleIdentificationResult(file, result, embeddingVector);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  void _handleIdentificationResult(
    XFile file,
    MatchResult result,
    List<double> vector,
  ) {
    Color statusColor;
    String title;
    String message;
    Widget actionWidget;

    if (result.type == MatchType.match) {
      statusColor = Colors.green;
      title = "¡Identificado!";
      message =
          "Parece ser: ${result.candidateName}\nConfianza: ${(result.confidence * 100).toStringAsFixed(1)}%";
      actionWidget = _buildMatchActions(result.candidateId!, vector, file);
    } else if (result.type == MatchType.possible) {
      statusColor = Colors.orange;
      title = "Posible Coincidencia";
      message =
          "¿Es este animal: ${result.candidateName}?\nConfianza: ${(result.confidence * 100).toStringAsFixed(1)}%";
      actionWidget = _buildPossibleMatchActions(
        result.candidateId!,
        vector,
        file,
      );
    } else {
      statusColor = Colors.blue;
      title = "Nuevo Animal Detectado";
      message = "No reconozco a este animal.\nSe recomienda registrarlo.";
      actionWidget = _buildNewAnimalActions(file, vector);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.lens, color: statusColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(file.path),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              actionWidget,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchActions(
    String candidateId,
    List<double> vector,
    XFile file,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.check_circle),
          label: const Text('Sí, Confirmar Identidad'),
          onPressed: () {
            _confirmMatch(candidateId, vector);
            Navigator.pop(context);
          },
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('No, es Nuevo Animal'),
          onPressed: () {
            Navigator.pop(context);
            _showRegistrationDialog(file, vector);
          },
        ),
        const SizedBox(height: 5),
        TextButton(
          child: const Text(
            'Forzar Coincidencia (Manual)',
            style: TextStyle(color: Colors.grey),
          ),
          onPressed: () {
            Navigator.pop(context);
            _showForceMatchSelector(vector);
          },
        ),
      ],
    );
  }

  Widget _buildPossibleMatchActions(
    String candidateId,
    List<double> vector,
    XFile file,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.check),
          label: const Text('Sí, es Correcto'),
          onPressed: () {
            _confirmMatch(candidateId, vector);
            Navigator.pop(context);
          },
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.person_add),
          label: const Text('No, Registrar Nuevo'),
          onPressed: () {
            Navigator.pop(context);
            _showRegistrationDialog(file, vector);
          },
        ),
        TextButton(
          child: const Text('Forzar Coincidencia'),
          onPressed: () {
            Navigator.pop(context);
            _showForceMatchSelector(vector);
          },
        ),
      ],
    );
  }

  Widget _buildNewAnimalActions(XFile file, List<double> vector) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.app_registration),
          label: const Text('Registrar Ahora'),
          onPressed: () {
            Navigator.pop(context);
            _showRegistrationDialog(file, vector);
          },
        ),
        const SizedBox(height: 5),
        OutlinedButton.icon(
          icon: const Icon(Icons.link),
          label: const Text('Forzar Coincidencia (Ya Existe)'),
          onPressed: () {
            Navigator.pop(context);
            _showForceMatchSelector(vector);
          },
        ),
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Future<void> _showForceMatchSelector(List<double> vector) async {
    final animalsFn = await _animalRepository.getAnimals();
    final animals = animalsFn.fold((l) => <Animal>[], (r) => r);

    if (animals.isEmpty) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay animales registrados.')),
        );
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Seleccionar Animal Manualmente'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: animals.length,
              itemBuilder: (ctx, i) {
                final a = animals[i];
                return ListTile(
                  leading: Text(a.species.isNotEmpty ? a.species[0] : '?'),
                  title: Text(a.name),
                  subtitle: Text(a.species),
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmMatch(a.id, vector);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _confirmMatch(String animalId, List<double> vector) async {
    final embedding = EmbeddingModel(
      id: const Uuid().v4(),
      animalId: animalId,
      vector: vector,
      modelVersion: 'MobileNetV2',
    );
    await _dataSource.cacheEmbedding(embedding);
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Identidad Confirmada y Aprendida!')),
      );
  }

  void _showRegistrationDialog(XFile file, List<double> vector) async {
    String predictedSpecies = 'Desconocida';
    try {
      predictedSpecies = await _idService.predictSpecies(vector);
    } catch (_) {}

    final nameController = TextEditingController();
    final speciesController = TextEditingController(text: predictedSpecies);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Registrar Nuevo"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(File(file.path), height: 100),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre o ID del Animal',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: speciesController,
                decoration: const InputDecoration(
                  labelText: 'Especie',
                  border: OutlineInputBorder(),
                  hintText: 'Ej: Vaca, Cabra, Oveja',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final id = const Uuid().v4();
                await _animalRepository.registerAnimal(
                  Animal(
                    id: id,
                    name: nameController.text,
                    species: speciesController.text,
                    breed: 'Desconocida',
                    registrationDate: DateTime.now(),
                    notes: 'Registrado por Cámara',
                  ),
                );

                await _confirmMatch(id, vector);

                if (mounted) {
                  Navigator.pop(ctx);
                }
              }
            },
            child: const Text('Guardar Registro'),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeCamera() async {
    bool granted = await _permissionService.requestCriticalPermissions();
    if (!granted) {
      setState(() => _errorMessage = 'Camera permissions denied.');
      return;
    }

    try {
      await _cameraService.initialize();
      setState(() => _isInitialized = true);
    } catch (e) {
      setState(() => _errorMessage = 'Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(body: Center(child: Text(_errorMessage!)));
    }
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Capture')),
      body: Stack(
        children: [
          CameraPreview(_cameraService.controller!),

          if (_isAnalyzing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Analyzing...',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: FloatingActionButton(
                onPressed: _isAnalyzing ? null : _captureAndAnalyze,
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.blue,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
