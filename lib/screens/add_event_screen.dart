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
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _guestController = TextEditingController();
  final _budgetController = TextEditingController();

  DateSelectionMode _dateMode = DateSelectionMode.single;
  DateTime? _singleDate;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  final List<DateTime> _multipleDates = [];

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _guestController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _pickSingleDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _singleDate = picked);
  }

  Future<void> _pickRangeStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _rangeStart = picked;
        // reset end if it's now before start
        if (_rangeEnd != null && _rangeEnd!.isBefore(_rangeStart!)) {
          _rangeEnd = null;
        }
      });
    }
  }

  Future<void> _pickRangeEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _rangeStart?.add(const Duration(days: 1)) ??
          DateTime.now().add(const Duration(days: 31)),
      firstDate: _rangeStart?.add(const Duration(days: 1)) ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _rangeEnd = picked);
  }

  Future<void> _addMultipleDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && !_multipleDates.contains(picked)) {
      // if (ToiEvent.maxMultipleDates != null && _multipleDates.length >= ToiEvent.maxMultipleDates!) return;
      setState(() {
        _multipleDates.add(picked);
        _multipleDates.sort();
      });
    }
  }

  bool _isDateValid() {
    switch (_dateMode) {
      case DateSelectionMode.single:
        return _singleDate != null;
      case DateSelectionMode.range:
        return _rangeStart != null && _rangeEnd != null;
      case DateSelectionMode.multiple:
        return _multipleDates.isNotEmpty;
    }
  }

  String _formatDate(DateTime d) => '${d.day}.${d.month}.${d.year}';

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
              // Image upload (optional)
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
                                "Upload Event Cover (optional)",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                          : null,
                ),
              ),
              const SizedBox(height: 24),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Event Name *"),
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
                            ? "Please name your event"
                            : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description *",
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
                            ? "Please add a description"
                            : null,
              ),
              const SizedBox(height: 24),

              // Date section
              Text(
                "Event Date *",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Mode selector
              SegmentedButton<DateSelectionMode>(
                segments: const [
                  ButtonSegment(
                    value: DateSelectionMode.single,
                    label: Text("Single"),
                  ),
                  ButtonSegment(
                    value: DateSelectionMode.range,
                    label: Text("Range"),
                  ),
                  ButtonSegment(
                    value: DateSelectionMode.multiple,
                    label: Text("Multiple"),
                  ),
                ],
                selected: {_dateMode},
                onSelectionChanged:
                    (val) => setState(() {
                      _dateMode = val.first;
                      // clear previous selections on mode switch
                      _singleDate = null;
                      _rangeStart = null;
                      _rangeEnd = null;
                      _multipleDates.clear();
                    }),
              ),
              const SizedBox(height: 16),

              // Single date
              if (_dateMode == DateSelectionMode.single)
                InkWell(
                  onTap: _pickSingleDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Select Date",
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _singleDate == null
                          ? "Tap to select"
                          : _formatDate(_singleDate!),
                    ),
                  ),
                ),

              // Range
              if (_dateMode == DateSelectionMode.range) ...[
                InkWell(
                  onTap: _pickRangeStart,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Start Date",
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _rangeStart == null
                          ? "Tap to select"
                          : _formatDate(_rangeStart!),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickRangeEnd,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "End Date",
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(
                      _rangeEnd == null
                          ? "Tap to select"
                          : _formatDate(_rangeEnd!),
                    ),
                  ),
                ),
              ],

              // Multiple dates
              if (_dateMode == DateSelectionMode.multiple) ...[
                if (_multipleDates.isEmpty)
                  const Text(
                    "No dates added yet",
                    style: TextStyle(color: Colors.grey),
                  ),
                ..._multipleDates.map(
                  (d) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.event),
                    title: Text(_formatDate(d)),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => _multipleDates.remove(d)),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _addMultipleDate,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Date"),
                ),
              ],

              const SizedBox(height: 24),

              // Guests + Budget
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _guestController,
                      decoration: const InputDecoration(
                        labelText: "Guests *",
                        prefixIcon: Icon(Icons.people_outline),
                      ),
                      keyboardType: TextInputType.number,
                      validator:
                          (val) =>
                              val == null || val.trim().isEmpty
                                  ? "Required"
                                  : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _budgetController,
                      decoration: const InputDecoration(
                        labelText: "Budget (₸) *",
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator:
                          (val) =>
                              val == null || val.trim().isEmpty
                                  ? "Required"
                                  : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() && _isDateValid()) {
                      final currentUser = AuthService.currentUser;

                      final newEvent = ToiEvent(
                        id: DateTime.now().toString(),
                        userId: currentUser.id,
                        title: _nameController.text.trim(),
                        description: _descriptionController.text.trim(),
                        dateMode: _dateMode,
                        singleDate:
                            _dateMode == DateSelectionMode.single
                                ? _singleDate
                                : null,
                        rangeStart:
                            _dateMode == DateSelectionMode.range
                                ? _rangeStart
                                : null,
                        rangeEnd:
                            _dateMode == DateSelectionMode.range
                                ? _rangeEnd
                                : null,
                        multipleDates:
                            _dateMode == DateSelectionMode.multiple
                                ? List.from(_multipleDates)
                                : null,
                        location: _locationController.text.trim(),
                        guestCount: int.parse(_guestController.text),
                        budget: double.parse(_budgetController.text),
                        imageUrl: _selectedImage?.path,
                      );

                      Provider.of<ToiProvider>(
                        context,
                        listen: false,
                      ).addEvent(newEvent);
                      Navigator.pop(context);
                    } else if (!_isDateValid()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select a date")),
                      );
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
