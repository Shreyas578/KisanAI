import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/kisan_widgets.dart';
import '../../../../core/theme/app_theme.dart';

class NoInternetScreen extends ConsumerWidget {
  const NoInternetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F0D),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off,
                size: 48,
                color: Color(0xFF00E676),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Internet Connection',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF0FFF4),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please check your connection and try again',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Color(0xFF8BA898),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              KisanButton(
                text: 'Retry',
                onPressed: () {},
                isPrimary: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}