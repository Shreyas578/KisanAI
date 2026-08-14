import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/kisan_widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PriceAlertsScreen extends ConsumerStatefulWidget {
  const PriceAlertsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PriceAlertsScreen> createState() => _PriceAlertsScreenState();
}

class _PriceAlertsScreenState extends ConsumerState<PriceAlertsScreen> {
  bool _isLoading = false;
  List<dynamic> _alerts = [];
  
  final _commodityController = TextEditingController();
  final _targetPriceController = TextEditingController();
  String _alertType = 'above'; // 'above' or 'below'

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  @override
  void dispose() {
    _commodityController.dispose();
    _targetPriceController.dispose();
    super.dispose();
  }

  Future<void> _fetchAlerts() async {
    setState(() => _isLoading = true);
    try {
      // In a real app, you would pass the auth token.
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.priceEndpoint}/alerts');
      final response = await http.get(uri).timeout(ApiConfig.connectionTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          _alerts = data ?? [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading alerts: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createAlert() async {
    if (_commodityController.text.isEmpty || _targetPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.priceEndpoint}/alerts');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'commodity': _commodityController.text.trim(),
          'targetPrice': double.parse(_targetPriceController.text.trim()),
          'alertType': _alertType,
        }),
      ).timeout(ApiConfig.connectionTimeout);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alert created successfully!'), backgroundColor: AppColors.accentGreen),
        );
        _commodityController.clear();
        _targetPriceController.clear();
        _fetchAlerts();
      } else {
        throw Exception('Failed to create alert');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating alert: $e'), backgroundColor: AppColors.dangerRed),
      );
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _deleteAlert(String alertId) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.priceEndpoint}/alerts/$alertId');
      final response = await http.delete(uri).timeout(ApiConfig.connectionTimeout);
      
      if (response.statusCode == 200) {
        _fetchAlerts();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting alert: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: KisanAppBar(title: 'Price Alerts', showSearch: false),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildCreateAlertCard(),
                const SizedBox(height: 24),
                Text('Your Active Alerts', style: AppTypography.titleMedium),
                const SizedBox(height: 16),
                if (_isLoading && _alerts.isEmpty)
                  const Center(child: CircularProgressIndicator(color: AppColors.accentGreen))
                else if (_alerts.isEmpty)
                  _buildEmptyState()
                else
                  ..._alerts.map((alert) => _buildAlertItem(alert)).toList(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateAlertCard() {
    return KisanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.orange),
              const SizedBox(width: 8),
              Text('Create New Alert', style: AppTypography.titleSmall),
            ],
          ),
          const SizedBox(height: 16),
          KisanInput(
            controller: _commodityController,
            labelText: 'Commodity',
            hintText: 'e.g., Wheat',
            prefixIcon: Icons.grass,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: KisanInput(
                  controller: _targetPriceController,
                  labelText: 'Target Price (₹)',
                  hintText: 'e.g., 2500',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.currency_rupee,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Condition', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.inputBorderUnfocused),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _alertType,
                          items: const [
                            DropdownMenuItem(value: 'above', child: Padding(padding: EdgeInsets.only(left: 16), child: Text('Drops Below'))),
                            DropdownMenuItem(value: 'below', child: Padding(padding: EdgeInsets.only(left: 16), child: Text('Rises Above'))),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _alertType = val);
                            }
                          },
                          dropdownColor: AppColors.surface,
                          style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          KisanButton(
            text: 'Set Alert',
            onPressed: _isLoading ? null : _createAlert,
            icon: const Icon(Icons.add_alert, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(dynamic alert) {
    final commodity = alert['commodity'] ?? 'Unknown';
    final targetPrice = alert['targetPrice'] ?? 0;
    final type = alert['alertType'] == 'above' ? 'Drops Below' : 'Rises Above';
    final isActive = alert['isActive'] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isActive ? AppColors.accentGreen.withValues(alpha: 0.3) : AppColors.borderSubtle),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isActive ? AppColors.accentGreen.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
          child: Icon(Icons.trending_up, color: isActive ? AppColors.accentGreen : Colors.grey),
        ),
        title: Text(commodity, style: AppTypography.titleSmall),
        subtitle: Text('Notify me when price $type ₹$targetPrice', style: AppTypography.bodySmall),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: AppColors.dangerRed),
          onPressed: () => _deleteAlert(alert['id'] ?? ''),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, style: BorderStyle.solid),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.notifications_off, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text('No active price alerts', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text(
              'Set up an alert above to get notified when prices reach your target.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
