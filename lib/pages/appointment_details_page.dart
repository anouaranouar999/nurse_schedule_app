import 'package:flutter/material.dart';
import 'package:appoint_pro/models/appointment.dart';
import 'package:appoint_pro/services/database_service.dart';

class AppointmentDetailsPage extends StatefulWidget {
  final Appointment appointment;

  const AppointmentDetailsPage({super.key, required this.appointment});

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _typeController;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.appointment.name);
    _typeController = TextEditingController(text: widget.appointment.type);
    _selectedDate = widget.appointment.dateTime;
    _selectedTime = TimeOfDay.fromDateTime(widget.appointment.dateTime);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Date and Time must be selected")),
      );
      return;
    }

    final updatedDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    widget.appointment.name = _nameController.text.trim();
    widget.appointment.type = _typeController.text.trim();
    widget.appointment.dateTime = updatedDateTime;

    await DatabaseService.updateAppointment(widget.appointment);

    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Appointment updated")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointment Details"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Name
                  TextFormField(
                    controller: _nameController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(labelText: "Name"),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return "Name is required";
                      if (value.trim().length < 3) return "At least 3 characters";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  /// Type
                  TextFormField(
                    controller: _typeController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(labelText: "Type"),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return "Type is required";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  /// Date Picker
                  ListTile(
                    enabled: _isEditing,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    title: Text(
                      _selectedDate == null
                          ? "Select Date"
                          : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _isEditing ? _pickDate : null,
                  ),
                  const SizedBox(height: 16),

                  /// Time Picker
                  ListTile(
                    enabled: _isEditing,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    title: Text(
                      _selectedTime == null ? "Select Time" : _selectedTime!.format(context),
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: _isEditing ? _pickTime : null,
                  ),
                  const SizedBox(height: 24),

                  if (_isEditing)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveChanges,
                            child: const Text("Save"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() => _isEditing = false);
                            },
                            child: const Text("Cancel"),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}