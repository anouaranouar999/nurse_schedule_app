import 'package:appoint_pro/models/appointment.dart';
import 'package:hive_flutter/hive_flutter.dart';


class DatabaseService {

  static const String boxName = "appointmentsBox";

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AppointmentAdapter());
    await Hive.openBox<Appointment>(boxName);
  }

  static Box<Appointment> getBox() {
    return Hive.box<Appointment>(boxName);
  }

  static Future<void> addAppointment(Appointment appointment) async {
    final box = getBox();
    await box.add(appointment);
  }

  static Future<void> updateAppointment(Appointment appointment) async {
    await appointment.save();
  }

  static Future<void> deleteAppointment(Appointment appointment) async {
    await appointment.delete();
  }

  static List<Appointment> getAllAppointments() {
    final box = getBox();
    return box.values.toList();
  }

  static void autoCompletePastAppointments() {
    final box = getBox();
    final now = DateTime.now();

    for (var appointment in box.values) {
      if (appointment.dateTime.isBefore(now) &&
          appointment.isCompleted == false) {
        appointment.isCompleted = true;
        appointment.save();
      }
    }
  }
}