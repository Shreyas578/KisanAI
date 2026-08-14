import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/kisan_widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/api_config.dart';
import '../../../../providers/farmer_profile_provider.dart';
import '../widgets/price_forecast_card.dart';
import '../widgets/demand_calendar_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/profitability_calculator_widget.dart';

class MarketPricesScreen extends ConsumerStatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  ConsumerState<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends ConsumerState<MarketPricesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCommodity = 'Wheat';
  String _selectedState = 'Maharashtra';
  String _selectedCity = 'Nashik';
  String _selectedPeriod = 'weekly';
  
  bool _isLoading = false;
  bool _isIntelligenceLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _commodityPrices = [];
  List<Map<String, dynamic>> _historicalPrices = [];
  Map<String, dynamic>? _selectedPrice;

  Map<String, dynamic>? _forecastData;
  Map<String, dynamic>? _demandData;
  List<dynamic> _newsList = [];

  final List<String> _commodities = [
    'Wheat', 'Rice', 'Maize', 'Sugarcane', 'Cotton', 'Soybean',
    'Groundnut', 'Sunflower', 'Mustard', 'Potato', 'Onion', 'Tomato',
  ];

  final List<String> _states = [
    'Maharashtra', 'Punjab', 'Haryana', 'Karnataka', 'Tamil Nadu',
    'Uttar Pradesh', 'Delhi', 'Gujarat', 'Bihar', 'Madhya Pradesh',
  ];

  final List<String> _cities = [
    'Nashik', 'Pune', 'Nagpur', 'Aurangabad', 'Ludhiana', 'Amritsar', 
    'Karnal', 'Mysore', 'Coimbatore', 'Lucknow', 'Ahmedabad', 'Patna', 'Indore'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final farmerProfile = ref.read(farmerProfileProvider);
      if (farmerProfile != null) {
        setState(() {
          if (farmerProfile.state.isNotEmpty && _states.contains(farmerProfile.state)) {
            _selectedState = farmerProfile.state;
          }
          if (farmerProfile.cropName != null && _commodities.contains(farmerProfile.cropName)) {
            _selectedCommodity = farmerProfile.cropName!;
          }
          if (farmerProfile.district.isNotEmpty && !_cities.contains(farmerProfile.district)) {
             _cities.insert(0, farmerProfile.district);
             _selectedCity = farmerProfile.district;
          } else if (farmerProfile.district.isNotEmpty) {
             _selectedCity = farmerProfile.district;
          }
        });
      }
      _loadAllData();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    _loadPriceData();
    _loadMarketIntelligence();
  }

  Future<void> _loadPriceData() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final uri = Uri.parse('${ApiConfig.priceEndpoint}/commodity?commodity=$_selectedCommodity&state=$_selectedState&period=week');
      final histUri = Uri.parse('${ApiConfig.priceEndpoint}/history?commodity=$_selectedCommodity&state=$_selectedState&city=$_selectedCity&period=$_selectedPeriod&count=10');
      
      final responses = await Future.wait([
        http.get(uri).timeout(ApiConfig.connectionTimeout),
        http.get(histUri).timeout(ApiConfig.connectionTimeout),
      ]);

      final response = responses[0];
      final histResponse = responses[1];

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] ?? json.decode(response.body);
        final marketData = data['market_data'] ?? data;
        final marketsList = marketData['markets'];

        if (marketsList != null) {
          final markets = marketsList as List;
          setState(() {
            _commodityPrices = markets.cast<Map<String, dynamic>>();
            if (_commodityPrices.isNotEmpty) {
              try {
                _selectedPrice = _commodityPrices.firstWhere(
                  (m) => (m['name'] ?? '').toString().toLowerCase().contains(_selectedCity.toLowerCase()) || 
                         (m['district'] ?? '').toString().toLowerCase().contains(_selectedCity.toLowerCase())
                );
              } catch (_) {
                _selectedPrice = _commodityPrices[0];
              }
            }
            if (histResponse.statusCode == 200) {
              final histData = json.decode(histResponse.body)['data'];
              if (histData is List) {
                _historicalPrices = histData.cast<Map<String, dynamic>>();
              }
            }
            _isLoading = false;
          });
          return;
        }
      }
      setState(() {
        _errorMessage = 'Failed to load price data (HTTP ${response.statusCode})';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading prices: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMarketIntelligence() async {
    setState(() => _isIntelligenceLoading = true);
    try {
      final forecastUri = Uri.parse('${ApiConfig.priceEndpoint}/forecast?commodity=$_selectedCommodity&state=$_selectedState&city=$_selectedCity');
      final demandUri = Uri.parse('${ApiConfig.priceEndpoint}/demand?commodity=$_selectedCommodity&state=$_selectedState&city=$_selectedCity');
      final newsUri = Uri.parse('${ApiConfig.newsEndpoint}?query=$_selectedCommodity $_selectedState');

      final responses = await Future.wait([
        http.get(forecastUri).timeout(ApiConfig.connectionTimeout),
        http.get(demandUri).timeout(ApiConfig.connectionTimeout),
        http.get(newsUri).timeout(ApiConfig.connectionTimeout),
      ]);

      setState(() {
        if (responses[0].statusCode == 200) _forecastData = json.decode(responses[0].body)['data'];
        if (responses[1].statusCode == 200) _demandData = json.decode(responses[1].body)['data'];
        if (responses[2].statusCode == 200) {
          final newsBody = json.decode(responses[2].body)['data'];
          if (newsBody is List) _newsList = newsBody;
        }
        _isIntelligenceLoading = false;
      });
    } catch (e) {
      setState(() => _isIntelligenceLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F0D),
        title: const Text('Market Intelligence', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentGreen,
          labelColor: AppColors.accentGreen,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Prices & Analytics'),
            Tab(text: 'Market News'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildFilters(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPricesTab(),
                _buildNewsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return KisanCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCommodity,
                  items: _commodities.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (val) {
                    setState(() => _selectedCommodity = val ?? 'Wheat');
                    _loadAllData();
                  },
                  dropdownColor: const Color(0xFF1A2420),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedState,
                  items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (val) {
                    setState(() => _selectedState = val ?? 'Maharashtra');
                    _loadAllData();
                  },
                  dropdownColor: const Color(0xFF1A2420),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCity,
                  items: _cities.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (val) {
                    setState(() => _selectedCity = val ?? 'Nashik');
                    _loadAllData();
                  },
                  dropdownColor: const Color(0xFF1A2420),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricesTab() {
    return RefreshIndicator(
      onRefresh: _loadAllData,
      color: AppColors.accentGreen,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.accentGreen))
              : _buildPriceDisplay(),
          const SizedBox(height: 16),
          PriceForecastCard(
            forecastData: _forecastData,
            isLoading: _isIntelligenceLoading,
          ),
          const SizedBox(height: 16),
          DemandCalendarWidget(
            demandData: _demandData,
            isLoading: _isIntelligenceLoading,
          ),
          const SizedBox(height: 16),
          if (!_isLoading && _commodityPrices.isNotEmpty)
            ProfitabilityCalculatorWidget(
              markets: _commodityPrices,
              selectedCity: _selectedCity,
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildNewsTab() {
    if (_isIntelligenceLoading && _newsList.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accentGreen));
    }
    
    if (_newsList.isEmpty) {
      return const Center(
        child: Text('No news available for this commodity.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _newsList.length,
      itemBuilder: (context, index) {
        final news = _newsList[index];
        return _buildNewsCard(news);
      },
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> news) {
    return Card(
      color: AppColors.surfaceElevated,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          if (news['url'] != null) {
            final uri = Uri.parse(news['url']);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(news['source'] ?? 'Agri News', style: const TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(news['published_at'] != null ? news['published_at'].toString().split('T')[0] : '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                news['title'] ?? 'No Title',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                news['summary'] ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.link, color: Colors.blueAccent, size: 16),
                  const SizedBox(width: 4),
                  const Text('Read full article', style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceDisplay() {
    if (_errorMessage != null) {
      return KisanCard(child: Padding(padding: const EdgeInsets.all(16), child: Text(_errorMessage!, style: const TextStyle(color: AppColors.dangerRed))));
    }
    
    if (_commodityPrices.isEmpty) {
      return const KisanCard(child: Padding(padding: EdgeInsets.all(16), child: Text('No price data available for selected location', style: TextStyle(color: AppColors.textSecondary))));
    }

    if (_selectedPrice == null) return const SizedBox();

    final minPrice = (_selectedPrice!['min'] ?? 0).toInt();
    final maxPrice = (_selectedPrice!['max'] ?? 0).toInt();
    final modalPrice = (_selectedPrice!['modal'] ?? 0).toInt();
    final marketName = _selectedPrice!['name'] ?? 'Market';

    return KisanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.accentGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    marketName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF2A3830)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPriceColumn('Min Price', minPrice, AppColors.textSecondary),
                _buildPriceColumn('Modal Price', modalPrice, AppColors.accentGreen, isMain: true),
                _buildPriceColumn('Max Price', maxPrice, AppColors.textSecondary),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF2A3830)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Price Trends', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'hourly', label: Text('1H', style: TextStyle(fontSize: 10))),
                    ButtonSegment(value: 'daily', label: Text('1D', style: TextStyle(fontSize: 10))),
                    ButtonSegment(value: 'weekly', label: Text('1W', style: TextStyle(fontSize: 10))),
                  ],
                  selected: {_selectedPeriod},
                  onSelectionChanged: (set) {
                    setState(() { _selectedPeriod = set.first; });
                    _loadPriceData();
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) => states.contains(WidgetState.selected) ? AppColors.accentGreen : const Color(0xFF151D19)),
                    foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) => states.contains(WidgetState.selected) ? Colors.black : AppColors.textSecondary),
                    padding: WidgetStateProperty.all(EdgeInsets.zero),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: SizedBox(
              height: 200,
              child: _buildCandleChart(),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF151D19),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
            ),
            child: Text(
              'Prices in ₹ / Quintal in $_selectedCity (${_selectedPeriod.toUpperCase()})',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandleChart() {
    if (_historicalPrices.isEmpty) {
      return const Center(child: Text('No historical data available for this city', style: TextStyle(color: AppColors.textSecondary)));
    }

    final displayData = _historicalPrices.reversed.toList(); // Oldest to newest
    
    // Find absolute min and max for Y axis scaling
    double globalMin = double.infinity;
    double globalMax = 0;
    
    for (var m in displayData) {
      final min = (m['min'] ?? 0).toDouble();
      final max = (m['max'] ?? 0).toDouble();
      if (min < globalMin && min > 0) globalMin = min;
      if (max > globalMax) globalMax = max;
    }
    
    if (globalMin == double.infinity) globalMin = 0;
    
    // Add 10% padding to Y axis
    final yPadding = (globalMax - globalMin) * 0.1;
    final minY = (globalMin - yPadding).clamp(0.0, double.infinity);
    final maxY = globalMax + yPadding;

    return Stack(
      children: [
        // Background wicks
        BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            minY: minY,
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= displayData.length) return const SizedBox.shrink();
                    final offset = displayData[value.toInt()]['periodOffset'] ?? displayData[value.toInt()]['weekOffset'];
                    String label;
                    if (offset == 0) {
                      label = 'Now';
                    } else {
                      label = offset.toString();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        label,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '₹${value.toInt()}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(
                color: const Color(0xFF2A3830),
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: displayData.asMap().entries.map((entry) {
              final idx = entry.key;
              final weekData = entry.value;
              final min = (weekData['min'] ?? 0).toDouble();
              final max = (weekData['max'] ?? 0).toDouble();
              final open = (weekData['open'] ?? min + (max-min)*0.4).toDouble();
              final close = (weekData['close'] ?? min + (max-min)*0.6).toDouble();
              final isGreen = close >= open;
              final color = isGreen ? AppColors.accentGreen : AppColors.dangerRed;
              
              return BarChartGroupData(
                x: idx,
                barRods: [
                  BarChartRodData(
                    fromY: min,
                    toY: max,
                    width: 2,
                    color: color,
                    borderRadius: BorderRadius.circular(0),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        // Foreground bodies
        BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            minY: minY,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => const Color(0xFF1A2420),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final weekData = displayData[group.x.toInt()];
                  final minVal = weekData['min'];
                  final maxVal = weekData['max'];
                  final openVal = weekData['open'] ?? minVal;
                  final closeVal = weekData['close'] ?? maxVal;
                  return BarTooltipItem(
                    'O: ₹$openVal  C: ₹$closeVal\nH: ₹$maxVal  L: ₹$minVal',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, m) => const SizedBox.shrink())),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, m) => const SizedBox.shrink())),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: displayData.asMap().entries.map((entry) {
              final idx = entry.key;
              final weekData = entry.value;
              final minVal = (weekData['min'] ?? 0).toDouble();
              final maxVal = (weekData['max'] ?? 0).toDouble();
              final open = (weekData['open'] ?? minVal + (maxVal-minVal)*0.4).toDouble();
              final close = (weekData['close'] ?? minVal + (maxVal-minVal)*0.6).toDouble();
              final isGreen = close >= open;
              final color = isGreen ? AppColors.accentGreen : AppColors.dangerRed;
              
              // body from open to close (or close to open)
              final bodyBottom = open < close ? open : close;
              final bodyTop = open > close ? open : close;

              return BarChartGroupData(
                x: idx,
                barRods: [
                  BarChartRodData(
                    fromY: bodyBottom,
                    toY: bodyTop == bodyBottom ? bodyTop + 0.5 : bodyTop, // ensure at least some height
                    width: 12,
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceColumn(String label, int value, Color color, {bool isMain = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Text(
          '₹$value',
          style: TextStyle(
            fontSize: isMain ? 24 : 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
