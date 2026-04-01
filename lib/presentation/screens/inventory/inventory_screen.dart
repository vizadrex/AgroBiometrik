import 'package:flutter/material.dart';

import '../../../core/services/service_locator.dart';
import '../../../domain/repositories/animal_repository.dart';
import '../../../domain/entities/animal.dart';
import 'package:uuid/uuid.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final AnimalRepository _repository = sl<AnimalRepository>();
  late Future<List<Animal>> _animalsFuture;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _animalsFuture = _repository.getAnimals().then(
        (either) => either.fold(
          (failure) => throw Exception(failure.message),
          (list) => list,
        ),
      );
    });
  }

  Future<void> _addOrEditAnimalDialog({Animal? animal}) async {
    final isEdit = animal != null;
    final nameController = TextEditingController(text: animal?.name ?? '');
    final speciesController = TextEditingController(
      text: animal?.species ?? 'Vaca',
    );
    final notesController = TextEditingController(text: animal?.notes ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Editar Animal' : 'Nuevo Animal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre / ID'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: speciesController,
                decoration: const InputDecoration(
                  labelText: 'Especie (Ej: Vaca, Oveja)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notas'),
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
                final newAnimal = Animal(
                  id: isEdit ? animal.id : const Uuid().v4(),
                  name: nameController.text,
                  species: speciesController.text,
                  breed: 'Desconocida',
                  registrationDate: isEdit
                      ? animal.registrationDate
                      : DateTime.now(),
                  notes: notesController.text,
                );

                final result = isEdit
                    ? await _repository.updateAnimal(newAnimal)
                    : await _repository.registerAnimal(newAnimal);

                result.fold(
                  (l) => ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l.message))),
                  (r) {
                    Navigator.pop(ctx);
                    _refreshList();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEdit ? 'Actualizado' : 'Guardado'),
                      ),
                    );
                  },
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAnimal(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar?'),
        content: const Text(
          'Esta acción borrará el animal y su aprendizaje asociado. No se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.deleteAnimal(id);
      _refreshList();
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Eliminado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventario')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditAnimalDialog(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Animal>>(
        future: _animalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final animals = snapshot.data ?? [];

          if (animals.isEmpty) {
            return const Center(
              child: Text('Sin registros. Presiona + para agregar.'),
            );
          }

          return ListView.builder(
            itemCount: animals.length,
            itemBuilder: (context, index) {
              final animal = animals[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      animal.species.isNotEmpty
                          ? animal.species[0].toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(
                    animal.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${animal.species} • Reg: ${animal.registrationDate.toLocal().toString().split(' ')[0]}',
                  ),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'edit')
                        _addOrEditAnimalDialog(animal: animal);
                      if (value == 'delete') _deleteAnimal(animal.id);
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 10),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 10),
                            Text('Eliminar'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _addOrEditAnimalDialog(animal: animal),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
