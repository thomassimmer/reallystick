import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:reallystick/features/habits/domain/entities/unit.dart';

class UnitDataModel extends Equatable {
  final String id;
  final Map<String, String> shortName;
  final Map<String, Map<String, String>> longName;

  const UnitDataModel({
    required this.id,
    required this.shortName,
    required this.longName,
  });

  factory UnitDataModel.fromJson(Map<String, dynamic> jsonObject) {
    return UnitDataModel(
      id: jsonObject['id'] as String,
      shortName: jsonObject['short_name'] != null
          ? Map<String, String>.from(
              json.decode(jsonObject['short_name'] as String))
          : {},
      longName: jsonObject['long_name'] != null
          ? Map<String, Map<String, String>>.from(
              (json.decode(jsonObject['long_name'] as String) as Map).map(
                (key, value) => MapEntry(
                  key as String,
                  Map<String, String>.from(value as Map),
                ),
              ),
            )
          : {},
    );
  }

  Unit toDomain() => Unit(
        id: id,
        shortName: shortName,
        longName: longName,
      );

  @override
  List<Object?> get props => [
        id,
        shortName,
        longName,
      ];
}
