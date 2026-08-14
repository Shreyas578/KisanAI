import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisan_ai/features/registration/providers/registration_state_provider.dart';

import 'step1_personal_details.dart';
import 'step2_farm_location.dart';
import 'step3_land_details.dart';
import 'step4_crop_selection.dart';
import 'step5_review_submit.dart';

class RegistrationWizardScreen extends ConsumerStatefulWidget {
  const RegistrationWizardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegistrationWizardScreen> createState() =>
      _RegistrationWizardScreenState();
}

class _RegistrationWizardScreenState
    extends ConsumerState<RegistrationWizardScreen> {
  late PageController _pageController;
  int _currentStep = 0;
  final int _totalSteps = 5;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    final role = ref.read(registrationStateProvider).role ?? 'farmer';
    if (role != 'farmer' && _currentStep == 0) {
      // Buyer and Seller skip straight to step 4 (Review)
      _pageController.animateToPage(
        4,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep = 4;
      });
      return;
    }

    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    final role = ref.read(registrationStateProvider).role ?? 'farmer';
    if (role != 'farmer' && _currentStep == 4) {
      // Buyer and Seller go straight back to step 0
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep = 0;
      });
      return;
    }

    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return Step1PersonalDetails(onNext: _nextStep);
      case 1:
        return Step2FarmLocation(onNext: _nextStep);
      case 2:
        return Step3LandDetails(onNext: _nextStep);
      case 3:
        return Step4CropSelectionScreen(
          onNext: _nextStep,
          onPrevious: _previousStep,
        );
      case 4:
        return Step5ReviewSubmitScreen(onPrevious: _previousStep);
      default:
        return const Center(child: Text('Unknown step'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _previousStep();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Farmer Registration',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.green.shade700,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _previousStep,
          ),
        ),
        body: Column(
          children: [
            // Shared Progress Indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / _totalSteps,
              minHeight: 6,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(Colors.green.shade700),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _totalSteps,
                itemBuilder: (context, index) {
                  return _buildStep();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
