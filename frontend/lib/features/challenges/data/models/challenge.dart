import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge.dart';

class ChallengeDataModel extends Equatable {
  final String id;
  final String creator;
  final Map<String, String> name;
  final Map<String, String> description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String icon;
  final bool deleted;

  const ChallengeDataModel({
    required this.id,
    required this.creator,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.icon,
    required this.deleted,
  });

  factory ChallengeDataModel.fromJson(Map<String, dynamic> jsonObject) {
    return ChallengeDataModel(
      id: jsonObject['id'] as String,
      creator: jsonObject['creator'] as String,
      name: Map<String, String>.from(json.decode(jsonObject['name'])),
      description:
          Map<String, String>.from(json.decode(jsonObject['description'])),
      startDate: jsonObject['start_date'] != null
          ? DateTime.parse(jsonObject['start_date'] as String)
          : null,
      endDate: jsonObject['end_date'] != null
          ? DateTime.parse(jsonObject['end_date'] as String)
          : null,
      icon: jsonObject['icon'] as String,
      deleted: jsonObject['deleted'] as bool,
    );
  }

  Challenge toDomain() => Challenge(
        id: id,
        creator: creator,
        name: name,
        startDate: startDate,
        description: description,
        icon: icon,
        deleted: deleted,
      );

  @override
  List<Object?> get props => [
        id,
        creator,
        name,
        description,
        startDate,
        endDate,
        icon,
        deleted,
      ];
}
