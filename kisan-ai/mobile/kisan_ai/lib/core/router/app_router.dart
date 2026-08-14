import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core screens
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/farmer_dashboard/screens/farmer_home_screen.dart';
import '../../shared/widgets/no_internet_screen.dart';
import '../../shared/widgets/loading_screen.dart';

// Registration Flow
import '../../features/registration/screens/registration_wizard_screen.dart';

// Feature screens
import '../../features/disease_detection/screens/disease_scan_screen.dart';
import '../../features/market/screens/market_prices_screen.dart';
import '../../features/chatbot/screens/chatbot_screen.dart';
import '../../features/farm_report/screens/farm_report_screen.dart';
import '../../features/marketplace/screens/marketplace_screen.dart';
import '../../features/marketplace/screens/cart_screen.dart';
import '../../features/marketplace/screens/search_results_screen.dart';
import '../../features/marketplace/screens/create_listing_screen.dart';
import '../../features/marketplace/screens/orders_screen.dart';
import '../../features/marketplace/screens/listing_detail_screen.dart';
import '../../features/weather/screens/weather_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/profile_edit_screen.dart';
import '../../features/government_scheme/screens/government_scheme_home_screen.dart';
import '../../features/government_scheme/screens/government_scheme_detail_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';

// Splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          GoRouter.of(context).go('/login');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F0D),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.agriculture,
                size: 48,
                color: Color(0xFF00E676),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'KISAN AI',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF0FFF4),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 64,
              height: 2,
              child: Container(color: const Color(0xFF00E676)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your field. Your data. Your power.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Color(0xFF8BA898),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Minimal router for MVP
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegistrationWizardScreen(),
    ),
    GoRoute(
      path: '/farmer/home',
      builder: (context, state) => const FarmerHomeScreen(),
    ),
    // Feature Routes
    GoRoute(
      path: '/weather',
      builder: (context, state) => const WeatherScreen(),
    ),
    GoRoute(
      path: '/disease-scan',
      builder: (context, state) => const DiseaseScanScreen(),
    ),
    GoRoute(
      path: '/schemes',
      builder: (context, state) => const GovernmentSchemeHomeScreen(),
    ),
    GoRoute(
      path: '/government-scheme-detail/:id',
      builder: (context, state) => GovernmentSchemeDetailScreen(
        schemeId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/market-prices',
      builder: (context, state) => const MarketPricesScreen(),
    ),
    GoRoute(
      path: '/farm-report',
      builder: (context, state) => const FarmReportScreen(),
    ),
    GoRoute(
      path: '/marketplace',
      builder: (context, state) => const MarketplaceScreen(),
    ),
    GoRoute(
      path: '/marketplace/listing/:id',
      builder: (context, state) => ListingDetailScreen(
        listingId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/create-listing',
      builder: (context, state) => const CreateListingScreen(),
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const OrdersScreen(),
    ),
    GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
    GoRoute(
      path: '/search',
      builder: (context, state) {
        final query = state.uri.queryParameters['q'];
        return SearchResultsScreen(initialQuery: query);
      },
    ),
    GoRoute(
      path: '/chatbot',
      builder: (context, state) => const ChatbotScreen(),
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const ProfileEditScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/schemes',
      builder: (context, state) => const GovernmentSchemeHomeScreen(),
    ),
    GoRoute(
      path: '/no-internet',
      builder: (context, state) => const NoInternetScreen(),
    ),
    GoRoute(
      path: '/loading',
      builder: (context, state) => const LoadingScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFF0A0F0D),
    body: Center(
      child: Text(
        'Page not found: ${state.uri}',
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          color: Color(0xFFF0FFF4),
        ),
      ),
    ),
  ),
);

// Provider for GoRouter
final appRouterProvider = Provider<GoRouter>((ref) {
  return appRouter;
});
