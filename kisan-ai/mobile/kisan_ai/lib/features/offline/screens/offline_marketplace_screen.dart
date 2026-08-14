import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kisan_ai/services/cache/marketplace_cache_service.dart';
import 'package:kisan_ai/core/connectivity/connectivity_service.dart';

/// Read-only marketplace screen using cached data
class OfflineMarketplaceScreen extends StatefulWidget {
  const OfflineMarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<OfflineMarketplaceScreen> createState() =>
      _OfflineMarketplaceScreenState();
}

class _OfflineMarketplaceScreenState extends State<OfflineMarketplaceScreen> {
  final MarketplaceCacheService _cache = MarketplaceCacheService();
  final ConnectivityService _connectivity = ConnectivityService();

  List<Map<String, dynamic>> _listings = [];
  bool _isLoading = true;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _initCache();
    _checkConnectivity();
  }

  Future<void> _initCache() async {
    try {
      await _cache.initialize();
      await _loadCachedListings();
    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ Cache init error: $e');
    }
  }

  void _checkConnectivity() {
    _connectivity.onStatusChange.listen((isOnline) {
      if (mounted) {
        setState(() => _isOnline = isOnline);
      }
    });
  }

  @override
  void dispose() {
    // Cleanup is handled by the listener disposal
    super.dispose();
  }

  Future<void> _loadCachedListings() async {
    final listings = await _cache.getCachedListings();
    if (mounted) {
      setState(() {
        _listings = listings ?? [];
        _isLoading = false;
      });
    }
  }

  void _showListingDetails(Map<String, dynamic> listing) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              listing['title'] ?? 'Product',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('💰 Price: ₹${listing['price'] ?? 0}'),
            Text(
              '📦 Quantity: ${listing['quantity'] ?? 0} ${listing['unit'] ?? 'unit'}',
            ),
            Text('🏷️ Category: ${listing['category'] ?? 'N/A'}'),
            const SizedBox(height: 16),
            Text(
              listing['description'] ?? 'No description available',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            if (_isOnline)
              ElevatedButton(
                onPressed: () {
                  _queueOrder(listing);
                  Navigator.pop(context);
                },
                child: const Text('📦 Place Order'),
              )
            else
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '📴 You are offline\nOrders will be queued and sent when online',
                  style: TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _queueOrder(Map<String, dynamic> listing) {
    _cache.queueOrder({
      'listingId': listing['id'],
      'title': listing['title'],
      'quantity': 1,
      'price': listing['price'],
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Order queued'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛒 Marketplace'),
        subtitle: _isOnline
            ? Text('${_listings.length} listings available')
            : const Text('📴 Offline - cached listings'),
      ),
      body: Column(
        children: [
          if (!_isOnline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange.shade100,
              child: const Row(
                children: [
                  Icon(Icons.cloud_off, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Viewing cached listings. Orders will sync when online.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _listings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text('No listings cached'),
                        if (_isOnline)
                          const Text('Connect to browse marketplace'),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: _listings.length,
                    itemBuilder: (context, index) {
                      final listing = _listings[index];
                      return GestureDetector(
                        onTap: () => _showListingDetails(listing),
                        child: Card(
                          elevation: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 100,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(4),
                                  ),
                                ),
                                child: listing['imageUrl'] != null
                                    ? CachedNetworkImage(
                                        imageUrl: listing['imageUrl'] as String,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            const Center(
                                              child: Icon(
                                                Icons
                                                    .image_not_supported_outlined,
                                                size: 48,
                                                color: Colors.grey,
                                              ),
                                            ),
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        listing['title'] ?? 'Product',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '₹${listing['price'] ?? 0}',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '${listing['quantity'] ?? 0}${listing['unit'] ?? 'pc'}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
