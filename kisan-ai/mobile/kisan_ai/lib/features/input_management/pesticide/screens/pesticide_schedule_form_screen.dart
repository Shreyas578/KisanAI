import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/features/input_management/pesticide/state/pesticide_provider.dart';
import 'package:kisan_ai/features/input_management/pesticide/services/pesticide_service.dart';
import 'package:kisan_ai/core/router/app_router.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';
import 'package:kisan_ai/shared/models/pesticide_model.dart';

class PesticideScheduleFormScreen extends ConsumerStatefulWidget {
  final String? scheduleId; // Null for create, non-null for edit

  const PesticideScheduleFormScreen({
    Key? key,
    this.scheduleId,
  }) : super(key: key);

  @override
  ConsumerState<PesticideScheduleFormScreen> createState() =>
      _PesticideScheduleFormScreenState();
}

class _PesticideScheduleFormScreenState
    extends ConsumerState<PesticideScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isLoading = true;

  // Form fields
  String? _pesticideType;
  String? _cropType;
  String? _applicationRate;
  String? _unit = 'L';
  String? _frequency;
  double? _area;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = true;

  // Dropdown options
  final List<String> _pesticideTypes = [
    'Insecticide',
    'Herbicide',
    'Fungicide',
    'Biopesticide',
    'Neem Oil',
    'Chemical Spray',
    'Organic Pesticide'
  ];

  final List<String> _cropTypes = [
    'Rice',
    'Wheat',
    'Cotton',
    'Sugarcane',
    'Vegetables',
    'Fruits'
  ];

  final List<String> _units = ['L', 'ml', 'g', 'kg'];

  final List<String> _frequencies = [
    'Once',
    'Weekly',
    'Bi-weekly',
    'Monthly',
    'Every 2 months',
    'Quarterly',
    'As needed'
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (widget.scheduleId != null) {
      // Load existing schedule for editing
      final scheduleAsync = ref.read(pesticideScheduleProvider(widget.scheduleId!));
      // We'll handle this in the build method using Consumer
    } else {
      // Set default values for new schedule
      setState(() {
        _isLoading = false;
        _startDate = DateTime.now();
        _endDate = DateTime.now().add(const Duration(days: 90)); // 3 months default
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text(
          widget.scheduleId == null ? 'Create Pesticide Schedule' : 'Edit Pesticide Schedule',
          style: AppTypography.titleLarge,
        ),
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accentGreen))
            : Consumer(
                builder: (context, ref, child) {
                  final scheduleAsync = widget.scheduleId != null
                      ? ref.watch(pesticideScheduleProvider(widget.scheduleId!))
                      : null;

                  return scheduleAsync?.when(
                    data: (schedule) => _buildFormWithData(schedule),
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentGreen)),
                    error: (error, stackTrace) => Center(
                      child: Text('Error loading schedule: $error',
                          style: TextStyle(color: AppColors.dangerRed)),
                    ),
                  ) ?? _buildFormWithData(null);
                },
              ),
      ),
      floatingActionButton: !_isSaving
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.accentGreen,
              onPressed: _saveSchedule,
              label: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryBackground,
                      ),
                    )
                  : const Text('Save Schedule'),
              icon: const Icon(Icons.save),
            )
          : null,
    );
  }

  Widget _buildFormWithData(PesticideSchedule? schedule) {
    // Initialize form values if editing
    if (schedule != null && _pesticideType == null) {
      setState(() {
        _pesticideType = schedule.pesticideType;
        _cropType = schedule.cropType;
        _applicationRate = schedule.applicationRate.toString();
        _unit = schedule.unit;
        _frequency = schedule.frequency;
        _area = schedule.area;
        _startDate = schedule.startDate;
        _endDate = schedule.endDate;
        _isActive = schedule.isActive;
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pesticide Type
            _buildDropdownField(
              label: 'Pesticide Type',
              value: _pesticideType ?? '',
              items: _pesticideTypes,
              onChanged: (value) => setState(() => _pesticideType = value),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please select pesticide type' : null,
            ),
            const SizedBox(height: 16),

            // Crop Type
            _buildDropdownField(
              label: 'Crop Type',
              value: _cropType ?? '',
              items: _cropTypes,
              onChanged: (value) => setState(() => _cropType = value),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please select crop type' : null,
            ),
            const SizedBox(height: 16),

            // Application Rate
            _buildTextField(
              label: 'Application Rate',
              hint: 'Enter application rate',
              initialValue: _applicationRate,
              onChanged: (value) => setState(() => _applicationRate = value),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter application rate';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            // Unit
            _buildDropdownField(
              label: 'Unit',
              value: _unit ?? '',
              items: _units,
              onChanged: (value) => setState(() => _unit = value!),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please select unit' : null,
            ),
            const SizedBox(height: 16),

            // Frequency
            _buildDropdownField(
              label: 'Frequency',
              value: _frequency ?? '',
              items: _frequencies,
              onChanged: (value) => setState(() => _frequency = value),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please select frequency' : null,
            ),
            const SizedBox(height: 16),

            // Area
            _buildTextField(
              label: 'Area (acres)',
              hint: 'Enter area in acres',
              initialValue: _area?.toString(),
              onChanged: (value) => setState(() => _area = double.tryParse(value)),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter area';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            // Start Date
            _buildDateField(
              label: 'Start Date',
              selectedDate: _startDate,
              onDateSelected: (date) => setState(() => _startDate = date),
            ),
            const SizedBox(height: 16),

            // End Date
            _buildDateField(
              label: 'End Date',
              selectedDate: _endDate,
              onDateSelected: (date) => setState(() => _endDate = date),
            ),
            const SizedBox(height: 24),

            // Active Status
            Row(
              children: [
                Checkbox(
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value!),
                  activeColor: AppColors.accentGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'Active Schedule',
                  style: AppTypography.bodyLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value.isEmpty ? null : value,
              items: items
                  .map((item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: AppTypography.bodyLarge.copyWith(
                            color: item == value
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: onChanged,
              dropdownColor: AppColors.surface,
            ),
          ),
        ),
        if (validator(value != null && value.isNotEmpty ? value : null) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              validator(value != null && value.isNotEmpty ? value : null)!,
              style: TextStyle(color: AppColors.dangerRed, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String? hint,
    required String? initialValue,
    required void Function(String) onChanged,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.surfaceElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.accentGreen),
            ),
          ),
          onChanged: onChanged,
          validator: validator,
          keyboardType: keyboardType,
        ),
        if (validator(_isSaving ? null : (initialValue ?? '')) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              validator(_isSaving ? null : (initialValue ?? ''))!,
              style: TextStyle(color: AppColors.dangerRed, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? selectedDate,
    required void Function(DateTime) onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              selectedDate == null
                  ? 'Select date'
                  : selectedDate.toString().split(' ')[0],
              style: AppTypography.bodyLarge.copyWith(
                color: selectedDate == null
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
            trailing: const Icon(
              Icons.calendar_today,
              color: AppColors.accentGreen,
            ),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null && picked != selectedDate) {
                onDateSelected(picked);
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> _saveSchedule() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final pesticideService =
          ref.read(pesticideServiceProvider);

      final scheduleData = PesticideSchedule(
        id: widget.scheduleId ?? '',
        pesticideType: _pesticideType!,
        cropType: _cropType!,
        applicationRate: double.parse(_applicationRate!),
        unit: _unit,
        frequency: _frequency!,
        area: _area!,
        startDate: _startDate!,
        endDate: _endDate,
        isActive: _isActive,
        isExecuting: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.scheduleId == null) {
        // Create new schedule
        await pesticideService.createSchedule(scheduleData);
      } else {
        // Update existing schedule
        await pesticideService.updateSchedule(widget.scheduleId!, scheduleData);
      }

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                widget.scheduleId == null
                    ? 'Pesticide schedule created successfully!'
                    : 'Pesticide schedule updated successfully!',
                style: TextStyle(color: AppColors.primaryBackground)),
            backgroundColor: AppColors.accentGreen,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to ${widget.scheduleId == null ? 'create' : 'update'} schedule: $e',
                style: TextStyle(color: AppColors.primaryBackground)),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }
}
