import '../../domain/entities/animal.dart';

class AnimalModel extends Animal {
  const AnimalModel({
    required super.id,
    required super.name,
    required super.species,
    super.breed,
    required super.registrationDate,
    super.notes,
  });

  factory AnimalModel.fromJson(Map<String, dynamic> json) {
    return AnimalModel(
      id: json['id'],
      name: json['name'],
      species: json['species'],
      breed: json['breed'],
      registrationDate: DateTime.parse(json['registration_date']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'registration_date': registrationDate.toIso8601String(),
      'notes': notes,
    };
  }
}
