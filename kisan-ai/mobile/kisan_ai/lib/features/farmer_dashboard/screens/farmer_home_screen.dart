import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:kisan_ai/core/config/api_config.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/providers/farmer_profile_provider.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';
import 'package:kisan_ai/shared/widgets/offline_banner.dart';
import 'package:kisan_ai/features/auth/state/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmerHomeScreen extends ConsumerStatefulWidget {
  const FarmerHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends ConsumerState<FarmerHomeScreen> {
  bool _isPriceLoading = true;
  bool _isWeatherLoading = true;

  Map<String, dynamic>? _priceSnapshot; // top commodity price
  Map<String, dynamic>? _weatherData;
  String _farmerState = 'Maharashtra';
  String _farmerName = 'Farmer';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDashboardData());
  }

  Future<void> _loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    final authState = ref.read(authProvider).valueOrNull;
    final userId = authState?.user?.id ?? prefs.getString('user_id') ?? '';

    var profile = ref.read(farmerProfileProvider);
    
    if (authState?.user != null) {
      if (mounted) {
        setState(() {
          final fullName = authState!.user!.name;
          _farmerName = fullName.isNotEmpty ? fullName.split(' ').first : 'User';
        });
      }
    }
    
    if (profile == null && userId.isNotEmpty) {
      try {
        final res = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/api/farm-profile/$userId'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (res.statusCode == 200) {
          final data = json.decode(res.body)['data'];
          if (data != null) {
            final newProfile = FarmerProfileModel(
              userId: userId,
              name: authState?.user?.name ?? 'Farmer',
              phone: authState?.user?.phone ?? '',
              latitude: data['latitude'] != null ? double.parse(data['latitude'].toString()) : 0.0,
              longitude: data['longitude'] != null ? double.parse(data['longitude'].toString()) : 0.0,
              state: data['state'] ?? 'Maharashtra',
              district: data['district'] ?? '',
              village: data['village'] ?? '',
              landAcres: data['land_area_acres'] != null ? double.parse(data['land_area_acres'].toString()) : 0.0,
              soilType: data['soil_type'] ?? '',
            );
            ref.read(farmerProfileProvider.notifier).initializeProfile(newProfile);
            profile = newProfile;
          }
        }
      } catch (e) {
        debugPrint('Failed to fetch farm profile: $e');
      }
    }

    if (profile != null) {
      setState(() {
        _farmerState = profile!.state.isNotEmpty ? profile!.state : 'Maharashtra';
        if (authState?.user == null || authState!.user!.name.isEmpty) {
          _farmerName = profile!.name.isNotEmpty ? profile!.name.split(' ').first : 'Farmer';
        }
      });
    }
    await Future.wait([_loadPriceSnapshot(), _loadWeather()]);
  }

  Future<void> _loadPriceSnapshot() async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.priceEndpoint}/commodity?commodity=Wheat&state=$_farmerState',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final data = json.decode(res.body)['data'] ?? json.decode(res.body);
        if (mounted) setState(() { _priceSnapshot = data; _isPriceLoading = false; });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _isPriceLoading = false);
  }

  Future<void> _loadWeather() async {
    try {
      final profile = ref.read(farmerProfileProvider);
      final lat = (profile != null && profile.latitude != 0) ? profile.latitude : 19.7515;
      final lon = (profile != null && profile.longitude != 0) ? profile.longitude : 75.7139;
      
      final uri = Uri.parse('${ApiConfig.weatherEndpoint}/current?lat=$lat&lon=$lon'); 
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = json.decode(res.body)['data'] ?? json.decode(res.body);
        if (mounted) setState(() { _weatherData = data; _isWeatherLoading = false; });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _isWeatherLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadDashboardData,
                color: AppColors.accentGreen,
                backgroundColor: const Color(0xFF1A2420),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),
                    SliverToBoxAdapter(child: _buildQuickStats()),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                        child: Text('Quick Access',
                          style: AppTypography.titleMedium.copyWith(color: AppColors.accentGreen)),
                      ),
                    ),
                    _buildFeatureGrid(),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1F17), Color(0xFF0A0F0D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.accentGreen.withOpacity(0.15),
            child: const Icon(Icons.person, color: AppColors.accentGreen, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$greeting, $_farmerName 🌾',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF0FFF4))),
                Text('$_farmerState · ${_formatDate()}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF8BA898))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF8BA898)),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          Expanded(child: _buildStatCard(
            icon: Icons.show_chart,
            label: 'Wheat Price',
            value: _isPriceLoading
              ? '...'
              : _priceSnapshot != null
                ? '₹${_priceSnapshot!['summary']?['avg_modal'] ?? '--'}/q'
                : 'Unavailable',
            sub: _isPriceLoading ? null : _priceSnapshot?['source'],
            color: const Color(0xFF00E676),
            onTap: () => context.push('/market-prices'),
          )),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard(
            icon: Icons.cloud,
            label: 'Weather',
            value: _isWeatherLoading
              ? '...'
              : _weatherData != null
                ? '${_weatherData!['temperature'] ?? '--'}°C'
                : 'N/A',
            sub: _isWeatherLoading ? null : (_weatherData?['description'] as String?)?.capitalize(),
            color: const Color(0xFF64B5F6),
            onTap: () => context.push('/weather'),
          )),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    String? sub,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF121F1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
              ],
            ),
            const SizedBox(height: 8),
            Text(value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF0FFF4))),
            if (sub != null) ...[
              const SizedBox(height: 2),
              Text(sub, style: const TextStyle(fontSize: 10, color: Color(0xFF8BA898)),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final allFeatures = [
      {'icon': Icons.show_chart,         'title': 'Market\nPrices',    'route': '/market-prices',  'color': const Color(0xFF00E676)},
      {'icon': Icons.biotech,            'title': 'Disease\nDetection','route': '/disease-scan',   'color': const Color(0xFFFF5252)},
      {'icon': Icons.assignment_outlined,'title': 'Farm\nReport',      'route': '/farm-report',    'color': const Color(0xFF64B5F6)},
      {'icon': Icons.storefront,         'title': 'Market\nplace',     'route': '/marketplace',    'color': const Color(0xFFFFD740)},
      {'icon': Icons.chat_bubble_outline,'title': 'Agri\nAssistant',   'route': '/chatbot',        'color': const Color(0xFFCE93D8)},
      {'icon': Icons.wb_sunny_outlined,  'title': 'Weather\nForecast', 'route': '/weather',        'color': const Color(0xFF80DEEA)},
      {'icon': Icons.account_balance,    'title': 'Govt\nSchemes',     'route': '/schemes',        'color': const Color(0xFFA5D6A7)},
      {'icon': Icons.receipt_long,       'title': 'Orders\nHistory',   'route': '/orders',         'color': const Color(0xFF90CAF9)},
      {'icon': Icons.person_outline,     'title': 'My\nProfile',       'route': '/profile',        'color': const Color(0xFFFFAB91)},
    ];

    final user = ref.watch(currentUserProvider);
    final role = user?.role.toLowerCase().trim() ?? 'farmer';

    final List<Map<String, dynamic>> features = (role == 'buyer' || role == 'supplier')
      ? allFeatures.where((f) => 
          f['route'] == '/market-prices' || 
          f['route'] == '/marketplace' || 
          f['route'] == '/orders' || 
          f['route'] == '/chatbot' || 
          f['route'] == '/profile'
        ).toList()
      : allFeatures;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = features[index];
          final color = item['color'] as Color;
          return GestureDetector(
            onTap: () => context.push(item['route'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: const Color(0xFF121F1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.15)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item['icon'] as IconData, color: color, size: 26),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item['title'] as String,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color.withOpacity(0.9)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }, childCount: features.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.15,
        ),
      ),
    );
  }

  String _formatDate() {
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

extension _StringExtension on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
