import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/features/registration/providers/registration_state_provider.dart';

class Step3LandDetails extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const Step3LandDetails({
    required this.onNext,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<Step3LandDetails> createState() => _Step3LandDetailsState();
}

class _Step3LandDetailsState extends ConsumerState<Step3LandDetails> {
  late TextEditingController _landAcresController;
  late TextEditingController _numPlotsController;
  late TextEditingController _equipmentController;

  String _soilType = 'loamy'; // Default soil type
  String _waterSource = 'borewell'; // Default water source
  String _irrigationType = 'drip'; // Default irrigation
  String? _topography = 'plain';
  bool _hasStorage = false;
  String? _budgetRange = 'medium';
  String? _marketPreference = 'local';
  String _riskAppetite = 'medium';
  bool _isLoading = false;
  String? _errorMessage;

  final _formKey = GlobalKey<FormState>();

  final List<Map<String, String>> _soilTypes = [
    {'value': 'clayey', 'label': '🌾 Clayey', 'icon': '🟤'},
    {'value': 'sandy', 'label': '🟡 Sandy', 'icon': '🟡'},
    {'value': 'loamy', 'label': '🟠 Loamy (Mixed)', 'icon': '🟠'},
    {'value': 'red', 'label': '🔴 Red Soil', 'icon': '🔴'},
    {'value': 'black', 'label': '⚫ Black Soil', 'icon': '⚫'},
    {'value': 'laterite', 'label': '🟤 Laterite', 'icon': '🟤'},
  ];

  final List<Map<String, String>> _waterSources = [
    {'value': 'well', 'label': '⛓️ Open Well'},
    {'value': 'borewell', 'label': '🔩 Borewell/Tubewell'},
    {'value': 'canal', 'label': '🌊 Canal/River'},
    {'value': 'tank', 'label': '💧 Tank/Pond'},
    {'value': 'rainwater', 'label': '🌧️ Rainwater Harvesting'},
  ];

  final List<Map<String, String>> _irrigationTypes = [
    {'value': 'drip', 'label': '💧 Drip Irrigation'},
    {'value': 'sprinkler', 'label': '🌧️ Sprinkler'},
    {'value': 'flood', 'label': '🌊 Flood/Basin'},
    {'value': 'furrow', 'label': '↔️ Furrow'},
    {'value': 'none', 'label': '🌾 Rain-fed'},
  ];

  final List<Map<String, String>> _topographies = [
    {'value': 'plain', 'label': 'Plain/Flat'},
    {'value': 'slope', 'label': 'Sloping'},
    {'value': 'undulating', 'label': 'Undulating'},
    {'value': 'hilly', 'label': 'Hilly'},
  ];

  @override
  void initState() {
    super.initState();
    _landAcresController = TextEditingController();
    _numPlotsController = TextEditingController(text: '1');
    _equipmentController = TextEditingController();
  }

  @override
  void dispose() {
    _landAcresController.dispose();
    _numPlotsController.dispose();
    _equipmentController.dispose();
    super.dispose();
  }

  Future<void> _submitLandDetails() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final sessionToken = ref.read(registrationStateProvider).sessionToken;
    if (sessionToken == null) {
      setState(() {
        _errorMessage = 'Session token not found. Please restart registration.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(registrationStateProvider.notifier).saveLandDetails(
            landAcres: double.parse(_landAcresController.text),
            numPlots: int.parse(_numPlotsController.text),
            soilType: _soilType,
            waterSource: _waterSource,
            irrigationType: _irrigationType,
            topography: _topography,
            equipment: _equipmentController.text.trim().isEmpty
                ? null
                : _equipmentController.text.trim(),
            hasStorage: _hasStorage,
            budgetRange: _budgetRange,
            marketPreference: _marketPreference,
            riskAppetite: _riskAppetite,
            sessionToken: sessionToken,
          );

      widget.onNext();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateLandAcres(String? value) {
    if (value == null || value.isEmpty) {
      return 'Land size is required';
    }
    try {
      final acres = double.parse(value);
      if (acres <= 0) {
        return 'Land size must be greater than 0';
      }
      if (acres > 10000) {
        return 'Land size seems too large, please verify';
      }
      return null;
    } catch (e) {
      return 'Enter a valid number';
    }
  }

  String? _validateNumPlots(String? value) {
    if (value == null || value.isEmpty) {
      return 'Number of plots is required';
    }
    try {
      final plots = int.parse(value);
      if (plots <= 0) {
        return 'Number of plots must be at least 1';
      }
      if (plots > 100) {
        return 'Number of plots seems too many, please verify';
      }
      return null;
    } catch (e) {
      return 'Enter a valid number';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Tell us about your land',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This helps us give better recommendations',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Land Size
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _landAcresController,
                      decoration: InputDecoration(
                        labelText: 'Land Size *',
                        hintText: '5',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.landscape),
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validateLandAcres,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Acres',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Number of Plots
              TextFormField(
                controller: _numPlotsController,
                decoration: InputDecoration(
                  labelText: 'Number of Plots',
                  hintText: '1',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.layers),
                ),
                keyboardType: TextInputType.number,
                validator: _validateNumPlots,
              ),
              const SizedBox(height: 24),

              // Soil Type
              Text(
                'Soil Type *',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _soilTypes.map((soil) {
                    final isSelected = _soilType == soil['value'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(
                          soil['label']!,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _soilType = soil['value']!;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Water Source
              Text(
                'Water Source *',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _waterSources.map((water) {
                    final isSelected = _waterSource == water['value'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(
                          water['label']!,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _waterSource = water['value']!;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Irrigation Type
              Text(
                'Irrigation Type *',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _irrigationTypes.map((irrig) {
                    final isSelected = _irrigationType == irrig['value'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(
                          irrig['label']!,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _irrigationType = irrig['value']!;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Topography
              Text(
                'Topography',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _topographies.map((topo) {
                    final isSelected = _topography == topo['value'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(
                          topo['label']!,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _topography = topo['value'];
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Equipment
              TextFormField(
                controller: _equipmentController,
                decoration: InputDecoration(
                  labelText: 'Equipment Available (Optional)',
                  hintText: 'E.g., Tractor, Pump, Harrow',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.build),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Storage
              CheckboxListTile(
                title: const Text('Do you have storage facility?'),
                subtitle: const Text('For grains or produce storage'),
                value: _hasStorage,
                onChanged: (value) {
                  setState(() {
                    _hasStorage = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Budget Range
              Text(
                'Expected Budget Range',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _budgetRange,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'low',
                    child: Text('💰 Low (< ₹50,000)'),
                  ),
                  DropdownMenuItem(
                    value: 'medium',
                    child: Text('💰💰 Medium (₹50K - 2L)'),
                  ),
                  DropdownMenuItem(
                    value: 'high',
                    child: Text('💰💰💰 High (> ₹2,00,000)'),
                  ),
                ].toList(),
                onChanged: (value) {
                  setState(() {
                    _budgetRange = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Market Preference
              Text(
                'Market Preference',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _marketPreference,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'local', child: Text('Local market')),
                  DropdownMenuItem(
                    value: 'wholesale',
                    child: Text('Wholesale'),
                  ),
                  DropdownMenuItem(
                    value: 'export',
                    child: Text('Export quality'),
                  ),
                ].toList(),
                onChanged: (value) {
                  setState(() {
                    _marketPreference = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Risk Appetite
              Text(
                'Risk Appetite',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _riskAppetite,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'low',
                    child: Text('Low - Traditional crops'),
                  ),
                  DropdownMenuItem(
                    value: 'medium',
                    child: Text('Medium - Balanced'),
                  ),
                  DropdownMenuItem(
                    value: 'high',
                    child: Text('High - High-value crops'),
                  ),
                ].toList(),
                onChanged: (value) {
                  setState(() {
                    _riskAppetite = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitLandDetails,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
