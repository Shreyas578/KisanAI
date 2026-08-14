import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/registration_state_provider.dart';

class _CropSuggestion {
  final String name;
  final String emoji;
  final int matchScore;
  final String shortReason;
  final List<String> detailedReasons;

  const _CropSuggestion({
    required this.name,
    required this.emoji,
    required this.matchScore,
    required this.shortReason,
    required this.detailedReasons,
  });
}

/// Step 4: Crop Selection
class Step4CropSelectionScreen extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const Step4CropSelectionScreen({
    Key? key,
    required this.onNext,
    required this.onPrevious,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _Step4CropSelectionScreenState();
}

class _Step4CropSelectionScreenState
    extends ConsumerState<Step4CropSelectionScreen> {
  late TextEditingController _cropNameController;
  late TextEditingController _seedVarietyController;
  late TextEditingController _previousCropController;
  late TextEditingController _budgetController;

  DateTime? _sowingDate;
  bool _cropDecided = true;
  bool _suggestionsLoading = false;
  bool _suggestionsLoaded = false;
  List<_CropSuggestion> _suggestions = [];
  _CropSuggestion? _selectedSuggestion;

  final List<String> popularCrops = [
    'Wheat', 'Rice', 'Maize', 'Cotton', 'Sugarcane',
    'Pulses', 'Vegetables', 'Fruits', 'Spices', 'Oil Seeds',
  ];

  @override
  void initState() {
    super.initState();
    _cropNameController = TextEditingController();
    _seedVarietyController = TextEditingController();
    _previousCropController = TextEditingController();
    _budgetController = TextEditingController();
  }

  @override
  void dispose() {
    _cropNameController.dispose();
    _seedVarietyController.dispose();
    _previousCropController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _sowingDate = picked);
  }

  List<_CropSuggestion> _generateSuggestionsFromState(RegistrationState s) {
    final soil = (s.soilType ?? '').toLowerCase();
    final water = (s.waterSource ?? '').toLowerCase();
    final state = (s.state ?? '').toLowerCase();
    final budget = (s.budgetRange ?? '').toLowerCase();
    final risk = (s.riskAppetite ?? 'medium').toLowerCase();

    // Build a contextual suggestion list based on farm data
    final allCrops = <_CropSuggestion>[
      _CropSuggestion(
        name: 'Wheat',
        emoji: '🌾',
        matchScore: (soil.contains('loam') || state.contains('punjab') || state.contains('haryana') || state.contains('up')) ? 95 : 72,
        shortReason: 'Highly stable, government MSP backed, ideal for your region',
        detailedReasons: [
          'Your soil type (${s.soilType ?? 'loam'}) is well-suited for wheat cultivation',
          'Strong government Minimum Support Price (MSP) ensures price stability',
          'High demand year-round in local and national markets',
          'Compatible with your ${s.irrigationType ?? 'irrigation'} setup',
          risk == 'low' ? 'Low-risk crop — perfect for conservative farming strategies' : 'Predictable growing cycle with established market channels',
        ],
      ),
      _CropSuggestion(
        name: 'Rice',
        emoji: '🍚',
        matchScore: (water.contains('canal') || water.contains('river') || soil.contains('clay')) ? 92 : 65,
        shortReason: 'Excellent water availability match, premium market value',
        detailedReasons: [
          'Your water source (${s.waterSource ?? 'canal'}) provides adequate supply for paddy cultivation',
          'Clay-based soils retain water exceptionally well for rice growing',
          'Strong export demand and consistent domestic pricing',
          'Proven crop rotation partner with pulses and wheat',
          'Government procurement programs available in most states',
        ],
      ),
      _CropSuggestion(
        name: 'Maize',
        emoji: '🌽',
        matchScore: (risk == 'high' || budget.contains('high') || budget.contains('above')) ? 88 : 78,
        shortReason: 'Fast growing, versatile usage, strong feed industry demand',
        detailedReasons: [
          'Shorter growing cycle (90–110 days) allows for 2–3 harvests per year',
          'Growing demand from poultry, starch, and ethanol industries',
          'More drought-tolerant than rice — suits varied water availability',
          'Higher profit margins possible with contract farming arrangements',
          'Your ${s.landAcres?.toStringAsFixed(1) ?? "farm"} acres qualifies for bulk supply contracts',
        ],
      ),
      _CropSuggestion(
        name: 'Pulses (Lentils/Chickpea)',
        emoji: '🫘',
        matchScore: (soil.contains('sandy') || soil.contains('black') || risk == 'low') ? 85 : 74,
        shortReason: 'Fixes soil nitrogen, low water requirement, government backed',
        detailedReasons: [
          'Naturally improves soil fertility by fixing atmospheric nitrogen',
          'Requires 40–50% less water than rice — great for water-scarce areas',
          'India imports large quantities — strong price support from government',
          'Excellent intercrop option with cereals to maximize land use',
          'Low input cost significantly reduces financial risk for your farm',
        ],
      ),
      _CropSuggestion(
        name: 'Vegetables (Seasonal)',
        emoji: '🥦',
        matchScore: (s.marketPreference?.toLowerCase().contains('local') == true || budget.contains('medium')) ? 82 : 70,
        shortReason: 'Highest returns per acre, quick cash flow within 2–3 months',
        detailedReasons: [
          'Returns of ₹80,000–₹2,00,000 per acre possible with proper management',
          'Fast cash cycle — harvest every 2–3 months keeps income regular',
          'Direct farm-to-market sales eliminate middlemen and increase margins',
          'High local demand ensures quick sales with minimal storage cost',
          'Your ${s.district ?? "district"} markets show strong vegetable demand trends',
        ],
      ),
    ];

    allCrops.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return allCrops.take(4).toList();
  }

  Future<void> _fetchSuggestions() async {
    final regState = ref.read(registrationStateProvider);
    setState(() { _suggestionsLoading = true; });

    // Simulate AI processing time
    await Future.delayed(const Duration(milliseconds: 1800));

    final suggestions = _generateSuggestionsFromState(regState);
    if (mounted) {
      setState(() {
        _suggestions = suggestions;
        _suggestionsLoading = false;
        _suggestionsLoaded = true;
      });
    }
  }

  Future<void> _proceedToNextStep() async {
    if (_cropDecided && _cropNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or select a crop name')),
      );
      return;
    }
    if (!_cropDecided && _selectedSuggestion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a crop from the suggestions to continue'),
          backgroundColor: Colors.orange.shade700,
        ),
      );
      return;
    }

    final sessionToken = ref.read(registrationStateProvider).sessionToken;
    if (sessionToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session token missing')),
      );
      return;
    }

    final finalCropName = _cropDecided
        ? _cropNameController.text
        : _selectedSuggestion!.name;

    try {
      await ref.read(registrationStateProvider.notifier).saveCropSelection(
        isDecided: _cropDecided,
        cropName: finalCropName,
        seedVariety: _seedVarietyController.text,
        sowingDate: _sowingDate?.toIso8601String(),
        previousCrop: _previousCropController.text,
        estimatedBudget: _budgetController.text,
        sessionToken: sessionToken,
      );
      widget.onNext();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(registrationLoadingProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: 0.8,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(Colors.green.shade700),
          ),
          const SizedBox(height: 20),
          Text('Step 4 of 5',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(height: 10),
          Text('Do you have a specific crop in mind?',
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade900)),
          const SizedBox(height: 10),
          Text(
            "Tell us if you've decided on a crop, or let our AI suggest the best options for your farm.",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 30),

          // Toggle
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green.shade700, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() { _cropDecided = true; _suggestionsLoaded = false; _selectedSuggestion = null; }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _cropDecided ? Colors.green.shade700 : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                      ),
                      child: Center(child: Text('✅  I Have a Crop',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: _cropDecided ? Colors.white : Colors.grey.shade700))),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() { _cropDecided = false; }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: !_cropDecided ? Colors.green.shade700 : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                      ),
                      child: Center(child: Text('🤔  Undecided',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: !_cropDecided ? Colors.white : Colors.grey.shade700))),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          if (_cropDecided) ..._buildDecidedFields()
          else ..._buildUndecidedSection(),

          if (_cropDecided) ...[
            const SizedBox(height: 20),
            Text('Previous Crop (Optional)',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _previousCropController,
              decoration: InputDecoration(
                hintText: 'What did you grow last season?',
                prefixIcon: const Icon(Icons.history),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true, fillColor: Colors.grey.shade100,
              ),
            ),
          ],

          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : widget.onPrevious,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.green.shade700),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Previous',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : _proceedToNextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Review & Submit',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDecidedFields() {
    return [
      Text('Crop Name *',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
      const SizedBox(height: 8),
      TextField(
        controller: _cropNameController,
        decoration: InputDecoration(
          hintText: 'e.g., Wheat, Rice, Cotton',
          prefixIcon: const Icon(Icons.grass),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true, fillColor: Colors.grey.shade100,
        ),
      ),
      const SizedBox(height: 12),
      Text('Popular Crops:',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: popularCrops.map((crop) {
          final isSelected = _cropNameController.text == crop;
          return GestureDetector(
            onTap: () => setState(() => _cropNameController.text = crop),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green.shade700),
                borderRadius: BorderRadius.circular(20),
                color: isSelected ? Colors.green.shade700 : Colors.white,
              ),
              child: Text(crop,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.green.shade700)),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 20),
      Text('Seed Variety (Optional)',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
      const SizedBox(height: 8),
      TextField(
        controller: _seedVarietyController,
        decoration: InputDecoration(
          hintText: 'e.g., HD2967, PR386',
          prefixIcon: const Icon(Icons.local_florist),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true, fillColor: Colors.grey.shade100,
        ),
      ),
      const SizedBox(height: 20),
      Text('Estimated Sowing Date (Optional)',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
      const SizedBox(height: 8),
      InkWell(
        onTap: _selectDate,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade100,
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.green),
              const SizedBox(width: 12),
              Text(
                _sowingDate == null
                    ? 'Select sowing date'
                    : DateFormat('dd MMM yyyy').format(_sowingDate!),
                style: GoogleFonts.poppins(
                    color: _sowingDate == null ? Colors.grey.shade600 : Colors.black),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildUndecidedSection() {
    return [
      // Info card
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.teal.shade50],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.green.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade700, shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text('AI Crop Intelligence',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 16,
                        color: Colors.green.shade900)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Our AI will analyze your soil type, water source, location, budget, and risk profile to suggest the most profitable crops for your farm.',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.green.shade800),
            ),
            const SizedBox(height: 8),
            ...[
              '📊 Yield & profitability estimation',
              '🌡️ Climate & soil compatibility score',
              '💰 Market demand & price trends',
              '🔄 Crop rotation advice',
            ].map((item) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(item,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.green.shade700)),
            )),
          ],
        ),
      ),
      const SizedBox(height: 20),

      // Budget field
      Text('Estimated Budget (Optional)',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
      const SizedBox(height: 8),
      TextField(
        controller: _budgetController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Enter budget in ₹',
          prefixIcon: const Icon(Icons.currency_rupee),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true, fillColor: Colors.grey.shade100,
        ),
      ),
      const SizedBox(height: 20),

      // Get Suggestions button
      if (!_suggestionsLoaded)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _suggestionsLoading ? null : _fetchSuggestions,
            icon: _suggestionsLoading
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.lightbulb_outline, color: Colors.white),
            label: Text(
              _suggestionsLoading ? 'Analyzing your farm data...' : '✨  Get AI Crop Suggestions',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade800,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),

      // Suggestions list
      if (_suggestionsLoaded) ...[
        Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 18),
            const SizedBox(width: 8),
            Text('Select one crop to continue:',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey.shade800)),
          ],
        ),
        const SizedBox(height: 12),
        ..._suggestions.map((s) => _buildSuggestionCard(s)).toList(),
      ],
    ];
  }

  Widget _buildSuggestionCard(_CropSuggestion suggestion) {
    final isSelected = _selectedSuggestion?.name == suggestion.name;
    return GestureDetector(
      onTap: () => setState(() => _selectedSuggestion = suggestion),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.green.shade700 : Colors.grey.shade200,
            width: isSelected ? 2.5 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.green.shade100, blurRadius: 8, offset: const Offset(0, 3))]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(suggestion.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(suggestion.name,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 16,
                                color: Colors.grey.shade900)),
                        Text(suggestion.shortReason,
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: suggestion.matchScore >= 85
                          ? Colors.green.shade700
                          : Colors.orange.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${suggestion.matchScore}% Match',
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: suggestion.matchScore / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(
                    suggestion.matchScore >= 85 ? Colors.green.shade600 : Colors.orange.shade500),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 12),
              Text('Why this crop?',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey.shade700)),
              const SizedBox(height: 6),
              ...suggestion.detailedReasons.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.arrow_right, size: 16, color: Colors.green.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(r,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey.shade700)),
                    ),
                  ],
                ),
              )),
              if (isSelected) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text('Selected — Tap "Review & Submit" to continue',
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
