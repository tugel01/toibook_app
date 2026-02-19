import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toibook_app/models/toi_event.dart';
import 'package:toibook_app/providers/toi_provider.dart';
import 'package:toibook_app/services/auth_service.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _guestController = TextEditingController();
  final _budgetController = TextEditingController();

  String? _selectedType;
  DateTime? _selectedDate;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _toiTypes = [
    "Үйлену той (Wedding)",
    "Қыз ұзату",
    "Мерейтой (Anniversary)",
    "Тұсаукесер",
    "Сүндет той",
    "Birthday Party",
  ];

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create New Toi")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.5),
                    ),
                    image:
                        _selectedImage != null
                            ? DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  child:
                      _selectedImage == null
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Upload Event Cover",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                          : null,
                ),
              ),
              const SizedBox(height: 24),

              // --- MANDATORY FIELDS ---
              Text(
                "Basic Information",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Event Name *",
                  hintText: "e.g. Alisher's Sunnet Toi",
                ),
                validator:
                    (val) => val!.isEmpty ? "Please name your event" : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: "Toi Type *"),
                items:
                    _toiTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _selectedType = val),
                validator: (val) => val == null ? "Please select a type" : null,
              ),
              const SizedBox(height: 16),

              // Date Picker Field
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Event Date *",
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? "Select Date"
                        : "${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}",
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // optional fields
              Text(
                "Extra Details",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: "Venue / Location",
                  prefixIcon: Icon(Icons.map_outlined),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _guestController,
                      decoration: const InputDecoration(
                        labelText: "Guests",
                        prefixIcon: Icon(Icons.people_outline),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _budgetController,
                      decoration: const InputDecoration(
                        labelText: "Budget (₸)",
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // --- SUBMIT BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _selectedDate != null) {
                      final currentUser = AuthService.currentUser;

                      if (currentUser == null) return;

                      final newEvent = ToiEvent(
                        id: DateTime.now().toString(),
                        userId: currentUser.id,
                        title: _nameController.text,
                        type: _selectedType!,
                        date: _selectedDate!,
                        location: _locationController.text,
                        guestCount: int.tryParse(_guestController.text),
                        budget: double.tryParse(_budgetController.text),
                        imageUrl: _selectedImage?.path,
                      );

                      Provider.of<ToiProvider>(
                        context,
                        listen: false,
                      ).addEvent(newEvent);

                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Create Event"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
