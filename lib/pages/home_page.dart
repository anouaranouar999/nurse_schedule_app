import 'package:flutter/material.dart';
import 'package:appoint_pro/pages/add_appointment_page.dart';
import 'package:appoint_pro/pages/appointment_details_page.dart';
import 'package:appoint_pro/models/appointment.dart';
import 'package:appoint_pro/services/database_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Appointment> appointments = [];

  @override
  void initState() {
    super.initState();
    DatabaseService.autoCompletePastAppointments(); 
    loadAppointments();
  }

  void loadAppointments() {
    final loadedAppointments = DatabaseService.getAllAppointments();
    setState(() {
      appointments = loadedAppointments;
      appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Appointments",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: appointments.isEmpty
          ? const Center(
              child: Text(
                "No appointments yet",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];

                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AppointmentDetailsPage(
                          appointment: appointment,
                        ),
                      ),
                    );
                    loadAppointments(); 
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      
                        Text(
                          appointment.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        Text(
                          "${appointment.dateTime.hour.toString().padLeft(2, '0')}:${appointment.dateTime.minute.toString().padLeft(2, '0')}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          final newAppointment = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddAppointmentPage(),
            ),
          );

          if (newAppointment != null && newAppointment is Appointment) {
            await DatabaseService.addAppointment(newAppointment);
            loadAppointments(); 
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}