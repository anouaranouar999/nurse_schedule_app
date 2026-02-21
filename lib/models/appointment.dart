import 'package:hive/hive.dart';

part 'appointment.g.dart';

@HiveType(typeId: 0)
class Appointment extends HiveObject {

  @HiveField(0)
  String name;

  @HiveField(1)
  String type;

  @HiveField(2)
  DateTime dateTime;

  @HiveField(3)
  bool isCompleted;

  Appointment({
    required this.name,
    required this.type,
    required this.dateTime,
    this.isCompleted = false,
  });
}