import 'package:equatable/equatable.dart';

class Animal extends Equatable {
  final String id;
  final String name;
  final String species;
  final String? breed;
  final DateTime registrationDate;
  final String? notes;

  const Animal({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    required this.registrationDate,
    this.notes,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    species,
    breed,
    registrationDate,
    notes,
  ];
}
