import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toibook_app/models/event/date_selection_mode.dart';
import 'package:toibook_app/models/event/event_date_dto.dart';
import 'package:toibook_app/providers/toi_provider.dart';
import 'package:provider/provider.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _guestController = TextEditingController();
  final _budgetController = TextEditingController();

  DateSelectionMode _dateMode = DateSelectionMode.singleDate;

  // Single date
  DateTime? _singleDate;

  // Range
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  // Multiple — each entry is (startDate, endDate, isSingleDay)
  final List<({DateTime start, DateTime end})> _multipleDates = [];

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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

  // For multiple mode, add a single day entry
  Future<void> _addSingleDayEntry() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _multipleDates.add((start: picked, end: picked)));
      _multipleDates.sort((a, b) => a.start.compareTo(b.start));
    }
  }

  // For multiple mode, add a range entry via bottom sheet
  Future<void> _addRangeEntry() async {
    DateTime? start;
    DateTime? end;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setModalState) => Padding(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 24,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Add Date Range',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(
                              const Duration(days: 30),
                            ),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setModalState(() => start = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Start Date',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            start == null
                                ? 'Tap to select'
                                : _formatDate(start!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap:
                            start == null
                                ? null
                                : () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: start!.add(
                                      const Duration(days: 1),
                                    ),
                                    firstDate: start!.add(
                                      const Duration(days: 1),
                                    ),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setModalState(() => end = picked);
                                  }
                                },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            prefixIcon: const Icon(
                              Icons.calendar_today_outlined,
                            ),
                            enabled: start != null,
                          ),
                          child: Text(
                            end == null
                                ? start == null
                                    ? 'Select start date first'
                                    : 'Tap to select'
                                : _formatDate(end!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed:
                              start != null && end != null
                                  ? () {
                                    setState(() {
                                      _multipleDates.add((
                                        start: start!,
                                        end: end!,
                                      ));
                                      _multipleDates.sort(
                                        (a, b) => a.start.compareTo(b.start),
                                      );
                                    });
                                    Navigator.pop(ctx);
                                  }
                                  : null,
                          child: const Text('Add Range'),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  bool _isDateValid() {
    switch (_dateMode) {
      case DateSelectionMode.singleDate:
        return _singleDate != null;
      case DateSelectionMode.dateRange:
        return _rangeStart != null && _rangeEnd != null;
      case DateSelectionMode.multipleDates:
        return _multipleDates.isNotEmpty;
    }
  }

  List<EventDateDto> _buildDates() {
    switch (_dateMode) {
      case DateSelectionMode.singleDate:
        return [EventDateDto(startDate: _singleDate!, endDate: _singleDate!)];
      case DateSelectionMode.dateRange:
        return [EventDateDto(startDate: _rangeStart!, endDate: _rangeEnd!)];
      case DateSelectionMode.multipleDates:
        return _multipleDates
            .map((e) => EventDateDto(startDate: e.start, endDate: e.end))
            .toList();
    }
  }

  String _formatDate(DateTime d) => '${d.day}.${d.month}.${d.year}';

  String _formatEntry(({DateTime start, DateTime end}) entry) {
    if (entry.start == entry.end) return _formatDate(entry.start);
    return '${_formatDate(entry.start)} — ${_formatDate(entry.end)}';
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
              // Image upload
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.5),
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
                                'Upload Event Cover (optional)',
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
                decoration: const InputDecoration(labelText: 'Event Name *'),
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
                            ? 'Please name your event'
                            : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
                            ? 'Please add a description'
                            : null,
              ),
              const SizedBox(height: 24),

              // Date section
              Text(
                'Event Date *',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              SegmentedButton<DateSelectionMode>(
                segments: const [
                  ButtonSegment(
                    value: DateSelectionMode.singleDate,
                    label: Text('Single'),
                  ),
                  ButtonSegment(
                    value: DateSelectionMode.dateRange,
                    label: Text('Range'),
                  ),
                  ButtonSegment(
                    value: DateSelectionMode.multipleDates,
                    label: Text('Multiple'),
                  ),
                ],
                selected: {_dateMode},
                onSelectionChanged:
                    (val) => setState(() {
                      _dateMode = val.first;
                      _singleDate = null;
                      _rangeStart = null;
                      _rangeEnd = null;
                      _multipleDates.clear();
                    }),
              ),
              const SizedBox(height: 16),

              // Single
              if (_dateMode == DateSelectionMode.singleDate)
                InkWell(
                  onTap: _pickSingleDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Select Date',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _singleDate == null
                          ? 'Tap to select'
                          : _formatDate(_singleDate!),
                    ),
                  ),
                ),

              // Range
              if (_dateMode == DateSelectionMode.dateRange) ...[
                InkWell(
                  onTap: _pickRangeStart,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _rangeStart == null
                          ? 'Tap to select'
                          : _formatDate(_rangeStart!),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickRangeEnd,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'End Date',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(
                      _rangeEnd == null
                          ? 'Tap to select'
                          : _formatDate(_rangeEnd!),
                    ),
                  ),
                ),
              ],

              // Multiple
              if (_dateMode == DateSelectionMode.multipleDates) ...[
                if (_multipleDates.isEmpty)
                  const Text(
                    'No dates added yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ..._multipleDates.map(
                  (entry) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.event),
                    title: Text(_formatEntry(entry)),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed:
                          () => setState(() => _multipleDates.remove(entry)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _addSingleDayEntry,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Single Day'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _addRangeEntry,
                        icon: const Icon(Icons.date_range, size: 18),
                        label: const Text('Range'),
                      ),
                    ),
                  ],
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
                        labelText: 'Guests *',
                        prefixIcon: Icon(Icons.people_outline),
                      ),
                      keyboardType: TextInputType.number,
                      validator:
                          (val) =>
                              val == null || val.trim().isEmpty
                                  ? 'Required'
                                  : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _budgetController,
                      decoration: const InputDecoration(
                        labelText: 'Budget (₸) *',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator:
                          (val) =>
                              val == null || val.trim().isEmpty
                                  ? 'Required'
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
                child: FilledButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () async {
                            if (!_formKey.currentState!.validate()) return;
                            if (!_isDateValid()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a date'),
                                ),
                              );
                              return;
                            }

                            setState(() => _isLoading = true);

                            try {
                              await context
                                  .read<ToiProvider>()
                                  .createAndRefresh(
                                    name: _nameController.text.trim(),
                                    description:
                                        _descriptionController.text.trim(),
                                    dateType: _dateMode,
                                    dates: _buildDates(),
                                    guestCount: int.parse(
                                      _guestController.text,
                                    ),
                                    budget: double.parse(
                                      _budgetController.text,
                                    ),
                                    coverImageUrl: null,
                                  );
                              if (!mounted) return;
                              Navigator.pop(context);
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Something went wrong: ${e.toString()}',
                                  ),
                                ),
                              );
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          },
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Create Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
