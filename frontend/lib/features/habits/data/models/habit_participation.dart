import 'package:equatable/equatable.dart';
import 'package:reallystick/features/habits/domain/entities/habit_participation.dart';

class HabitParticipationDataModel extends Equatable {
  final String id;
  final String userId;
  final String habitId;
  final String color;
  final bool toGain;

  const HabitParticipationDataModel({
    required this.id,
    required this.userId,
    required this.habitId,
    required this.color,
    required this.toGain,
  });

  factory HabitParticipationDataModel.fromJson(Map<String, dynamic> json) {
    return HabitParticipationDataModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      habitId: json['habit_id'] as String,
      color: json['color'] as String,
      toGain: json['to_gain'] as bool,
    );
  }

  HabitParticipation toDomain() => HabitParticipation(
        id: id,
        userId: userId,
        habitId: habitId,
        color: color,
        toGain: toGain,
      );

  @override
  List<Object?> get props => [
        id,
        userId,
        habitId,
        color,
        toGain,
      ];
}
