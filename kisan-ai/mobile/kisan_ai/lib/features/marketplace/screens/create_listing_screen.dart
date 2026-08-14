import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kisan_ai/core/router/app_router.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/features/marketplace/state/marketplace_provider.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';
import 'package:kisan_ai/shared/models/marketplace_listing_model.dart';
import 'package:kisan_ai/core/config/api_config.dart';
import 'package:kisan_ai/providers/farmer_profile_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kisan_ai/features/auth/state/auth_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final List<Uint8List> _images = [];
  String _title = '';
  String _description = '';
  String _category = 'Grains & Cereals';
  String _subcategory = 'Rice';
  String _variety = '';
  double _price = 0;
  String _unit = 'quintal';
  double _quantity = 0;
  String _location = '';
  bool _isOrganic = false;
  bool _isAvailableForShipping = true;
  bool _isNegotiable = true;
  bool _isLoading = false;
  bool _isCalculatingSmartPrice = false;
  
  double? _aiSuggestedPrice;
  String? _marketDemand;
  bool _isFetchingInsight = false;

  final List<String> _categories = [
    'Grains & Cereals',
    'Vegetables',
    'Fruits',
    'Cash Crops',
    'Spices',
    'Organic Produce',
    'Dairy & Poultry',
    'Farm Equipment',
    'Seeds & Fertilizers',
  ];

  final Map<String, List<String>> _subcategories = {
    'Grains & Cereals': [
      'Rice',
      'Wheat',
      'Maize',
      'Barley',
      'Millet',
      'Sorghum',
    ],
    'Vegetables': [
      'Tomato',
      'Onion',
      'Potato',
      'Carrot',
      'Spinach',
      'Broccoli',
    ],
    'Fruits': ['Mango', 'Banana', 'Apple', 'Orange', 'Grapes', 'Watermelon'],
    'Cash Crops': ['Cotton', 'Sugarcane', 'Tobacco', 'Jute', 'Tea', 'Coffee'],
    'Spices': ['Turmeric', 'Cumin', 'Coriander', 'Chili', 'Pepper', 'Cardamom'],
    'Organic Produce': [
      'Organic vegetables',
      'Organic Fruits',
      'Organic Grains',
      'Organic Pulses',
    ],
  };

  final List<String> _units = [
    'kg',
    'quintal',
    'ton',
    'piece',
    'dozen',
    'bundle',
    'sack',
    'bag',
    'crate',
    'basket',
  ];

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await ImagePicker().pickMultiImage(imageQuality: 80);
      if (pickedFiles.isNotEmpty) {
        final List<Uint8List> images = [];
        for (var file in pickedFiles) {
          final bytes = await file.readAsBytes();
          images.add(bytes);
        }
        setState(() {
          _images.addAll(images);
        });
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking images: $e'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );

        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json&addressdetails=1',
        );
        final response = await http.get(
          url,
          headers: {'User-Agent': 'KisanAI/1.0'},
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final address = data['address'] ?? {};
          final village = address['village'] ?? address['town'] ?? address['city'] ?? '';
          final district = address['county'] ?? address['state_district'] ?? address['district'] ?? '';
          final state = address['state'] ?? '';
          
          final locationParts = [village, district, state]
              .where((e) => e.toString().isNotEmpty)
              .join(', ');
              
          setState(() {
            _locationController.text = locationParts;
            _location = locationParts;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _fetchAIPriceInsight(String commodity) async {
    if (commodity.isEmpty) return;
    
    setState(() {
      _isFetchingInsight = true;
      _aiSuggestedPrice = null;
      _marketDemand = null;
    });

    try {
      final profile = ref.read(farmerProfileProvider);
      final state = profile?.state ?? 'Maharashtra';
      
      final priceUri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.priceEndpoint}/commodity?commodity=$commodity&state=$state&period=week');
      final response = await http.get(priceUri).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        if (data != null && data['market_data'] != null) {
          final markets = data['market_data']['markets'] as List;
          if (markets.isNotEmpty) {
            final modal = markets[0]['modal'];
            final demand = (markets[0]['max'] ?? 0) > (modal * 1.1) ? 'High' : 'Normal';
            if (mounted) {
              setState(() {
                _aiSuggestedPrice = (modal as num).toDouble();
                _marketDemand = demand;
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch AI price insight: $e');
    } finally {
      if (mounted) {
        setState(() => _isFetchingInsight = false);
      }
    }
  }

  Future<void> _submitListing() async {
    if (_formKey.currentState!.validate() && _images.isNotEmpty) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        // Step 1: Upload all images to IPFS
        final List<String> ipfsHashes = await _uploadListingImages();

        if (ipfsHashes.isEmpty && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload images. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }

        // Show success message for image uploads
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Images uploaded to IPFS: ${ipfsHashes.length} files',
              ),
              backgroundColor: AppColors.accentGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Step 2: Create listing with IPFS image hashes
        final listing = MarketplaceListing(
          id: '', // Will be generated by server
          sellerId: '', // Should come from auth
          sellerName: '', // Should come from auth/profile
          title: _title,
          description: _description,
          category: _category,
          subcategory: _subcategory,
          productName: _title, // Use title as product name
          variety: _variety,
          quantity: _quantity,
          unit: _unit,
          pricePerUnit: _price,
          currency: 'INR',
          isNegotiable: _isNegotiable,
          location: _location,
          state: '', // TODO: Get from user selection
          district: '', // TODO: Get from user selection
          images: ipfsHashes, // Use IPFS hashes instead of placeholder URLs
          qualityGrade: 'standard', // TODO: Let user select
          isVerified: false, // New listings are not verified by default
          postedAt: DateTime.now(),
          status: 'active',
          isFeatured: false,
        );

        // Use the provider to create the listing
        final marketplaceService = ref.read(marketplaceServiceProvider);
        final createdListing = await marketplaceService.createListing(listing);

        if (mounted) {
          setState(() => _isLoading = false);
          // Navigate to listing detail or show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Listing created successfully!'),
              backgroundColor: AppColors.accentGreen,
            ),
          );

          // Navigate to home or listing detail
          // In a real app, you'd go to the listing detail
          if (mounted) {
            ref.read(appRouterProvider).go('/');
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create listing: $e'),
              backgroundColor: AppColors.dangerRed,
            ),
          );
        }
      }
    }
  }

  Future<List<String>> _uploadListingImages() async {
    final ipfsHashes = <String>[];

    try {
      if (_images.isEmpty) {
        return ipfsHashes;
      }

      // Use batch upload endpoint for better performance
      if (_images.length > 1) {
        return await _batchUploadImages();
      }

      // Single image upload
      try {
        final uri = Uri.parse('${ApiConfig.baseUrl}/api/ipfs/upload');
        final request = http.MultipartRequest('POST', uri);
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            _images[0],
            filename: 'listing_0_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );
        request.fields['uploadType'] = 'marketplace';
        request.fields['farmId'] =
            'current'; // Would use farmer ID from profile

        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }

        final response = await request.send().timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw Exception('Upload timeout'),
        );

        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          final data = json.decode(responseBody);
          final item = data['data'];
          if (item != null) {
            String imageUrl = item['gatewayUrl'] ?? '';
            if (imageUrl.isEmpty) {
              final localPath = item['localPath'] as String?;
              if (localPath != null && localPath.isNotEmpty) {
                // Convert to full URL using base URL
                imageUrl = '${ApiConfig.baseUrl}/${localPath.replaceAll('\\', '/')}';
              } else {
                imageUrl = item['ipfsHash'] ?? '';
              }
            }
            if (imageUrl.isNotEmpty) {
              ipfsHashes.add(imageUrl);
            }
          }
        } else {
          print('Image upload failed: ${response.statusCode}');
        }
      } catch (e) {
        print('Error uploading image: $e');
      }
    } catch (e) {
      print('Upload error: $e');
    }

    return ipfsHashes;
  }

  /// Batch upload multiple images to IPFS
  /// Uses the optimized batch endpoint for faster upload
  Future<List<String>> _batchUploadImages() async {
    final ipfsHashes = <String>[];

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/ipfs/upload-batch');
      final request = http.MultipartRequest('POST', uri);

      // Add all images to the batch request
      for (int i = 0; i < _images.length; i++) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'files',
            _images[i],
            filename:
                'listing_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );
      }

      request.fields['uploadType'] = 'marketplace';
      request.fields['farmId'] = 'current';

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Batch upload timeout'),
      );

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);

        if (data['data'] is List) {
          for (var item in data['data']) {
            String imageUrl = item['gatewayUrl'] ?? '';
            if (imageUrl.isEmpty) {
              final localPath = item['localPath'] as String?;
              if (localPath != null && localPath.isNotEmpty) {
                // Convert to full URL using base URL
                imageUrl = '${ApiConfig.baseUrl}/${localPath.replaceAll('\\', '/')}';
              } else {
                imageUrl = item['ipfsHash'] ?? '';
              }
            }
            if (imageUrl.isNotEmpty) {
              ipfsHashes.add(imageUrl);
            }
          }
        }

        print('Batch upload completed: ${ipfsHashes.length} images');
      } else {
        print('Batch upload failed: ${response.statusCode}');
        // Fallback to individual uploads
        return await _fallbackIndividualUpload();
      }
    } catch (e) {
      print('Batch upload error: $e');
      // Fallback to individual uploads
      return await _fallbackIndividualUpload();
    }

    return ipfsHashes;
  }

  /// Fallback individual upload if batch fails
  Future<List<String>> _fallbackIndividualUpload() async {
    final ipfsHashes = <String>[];

    try {
      for (int i = 0; i < _images.length; i++) {
        try {
          final uri = Uri.parse('${ApiConfig.baseUrl}/api/ipfs/upload');
          final request = http.MultipartRequest('POST', uri);
          request.files.add(
            http.MultipartFile.fromBytes(
              'file',
              _images[i],
              filename:
                  'listing_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          );
          request.fields['uploadType'] = 'marketplace';
          request.fields['farmId'] = 'current';

          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          if (token != null && token.isNotEmpty) {
            request.headers['Authorization'] = 'Bearer $token';
          }

          final response = await request.send().timeout(
            const Duration(seconds: 20),
            onTimeout: () => throw Exception('Upload timeout'),
          );

          if (response.statusCode == 200) {
            final responseBody = await response.stream.bytesToString();
            final data = json.decode(responseBody);
            final hash = data['data']['ipfsHash'] ?? '';
            if (hash.isNotEmpty) {
              ipfsHashes.add(hash);
            }
          }
        } catch (e) {
          print('Fallback image $i upload failed: $e');
          // Continue with other images
        }
      }
    } catch (e) {
      print('Fallback upload error: $e');
    }

    return ipfsHashes;
  }

  Future<void> _calculateSmartPrice() async {
    _formKey.currentState?.save(); // Save current values to variables

    final commodity = _title.isNotEmpty ? _title : _category;
    if (commodity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a product title first')),
      );
      return;
    }

    setState(() => _isCalculatingSmartPrice = true);

    try {
      final farmerProfile = ref.read(farmerProfileProvider);
      final farmerState = farmerProfile?.state ?? 'Maharashtra';
      final state = _location.isNotEmpty ? _location : farmerState;

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/marketplace/suggest-price');
      final body = json.encode({
        'crop': commodity,
        'location': state,
        'date': DateTime.now().toIso8601String(),
        'quantity': _quantity,
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final headers = {'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        uri, 
        headers: headers,
        body: body
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        if (mounted && data != null) {
          _showSmartPricePopup(data);
        }
      } else {
        throw Exception('Failed to calculate');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not calculate smart price: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCalculatingSmartPrice = false);
      }
    }
  }

  void _showSmartPricePopup(Map<String, dynamic> data) {
    final suggestedPrice = data['suggested_price'] ?? 0;
    final reasoning = data['reasoning'] ?? 'AI calculated this price based on current market trends.';
    final confidence = data['confidence'] ?? 'Medium';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.surface,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.accentGreen),
                const SizedBox(width: 8),
                Text('Smart Listing Price', style: AppTypography.titleLarge),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              reasoning,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                '₹$suggestedPrice / $_unit',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.accentGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceElevated,
                      foregroundColor: AppColors.textPrimary,
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _price = suggestedPrice.toDouble());
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Apply Price'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: KisanAppBar(title: 'Create Listing'),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentGreen,
                        ),
                      )
                    : Form(
                        key: _formKey,
                        child: ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            // Images Section
                            _buildImagesSection(),
                            const SizedBox(height: 16),
                            // Basic Info
                            _buildTextFormField(
                              label: 'Product Title *',
                              hint: 'Enter product title',
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Please enter a title'
                                  : null,
                              onSaved: (value) => _title = value!,
                            ),
                            const SizedBox(height: 16),
                            _buildTextFormField(
                              label: 'Description *',
                              hint: 'Describe your product',
                              maxLines: 4,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Please enter a description'
                                  : null,
                              onSaved: (value) => _description = value!,
                            ),
                            const SizedBox(height: 16),
                            // Category Selection
                            _buildDropdownFormField(
                              label: 'Category *',
                              value: ref.read(authProvider).valueOrNull?.user?.role == 'supplier' ? 'Farm Equipment' : _category,
                              items: ref.read(authProvider).valueOrNull?.user?.role == 'supplier' ? ['Farm Equipment'] : _categories,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Please select a category'
                                  : null,
                              onSaved: (value) {
                                _category = value!;
                                _subcategory = _subcategories[_category]?.isNotEmpty == true 
                                    ? _subcategories[_category]!.first 
                                    : '';
                              },
                              onChanged: (value) {
                                setState(() {
                                  _category = value!;
                                  _subcategory = _subcategories[_category]?.isNotEmpty == true 
                                      ? _subcategories[_category]!.first 
                                      : '';
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            // Subcategory (if applicable)
                            if (_subcategories[_category] != null &&
                                _subcategories[_category]!.isNotEmpty)
                              _buildDropdownFormField(
                                label: 'Subcategory',
                                value: _subcategory,
                                items: _subcategories[_category]!,
                                onSaved: (value) => _subcategory = value ?? '',
                                onChanged: (value) {
                                  setState(() => _subcategory = value ?? '');
                                  if (value != null && value.isNotEmpty) {
                                    _fetchAIPriceInsight(value);
                                  }
                                },
                              ),
                            const SizedBox(height: 16),
                            
                            // AI Price Insight Badge
                            if (_isFetchingInsight)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentGreen)),
                                    SizedBox(width: 8),
                                    Text('Fetching live market prices...', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              )
                            else if (_aiSuggestedPrice != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.infoBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.infoBlue.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.insights, color: AppColors.infoBlue),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Current Market Value',
                                            style: AppTypography.labelSmall.copyWith(color: AppColors.infoBlue),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '₹${_aiSuggestedPrice!.toInt()} / $_unit',
                                            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_marketDemand == 'High')
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.dangerRed.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'High Demand 🔥',
                                          style: AppTypography.labelSmall.copyWith(color: AppColors.dangerRed, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 16),
                            // Variety/Type
                            _buildTextFormField(
                              label: 'Variety/Type (optional)',
                              hint: 'e.g., Basmati, Hybrid, Local',
                              onSaved: (value) => _variety = value ?? '',
                            ),
                            const SizedBox(height: 16),
                            // Pricing
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildTextFormField(
                                    label: 'Price *',
                                    hint: 'Enter price',
                                    controller: TextEditingController(
                                      text: _price > 0 ? _price.toString() : '',
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a price';
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'Please enter a valid number';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) =>
                                        _price = double.tryParse(value ?? '') ?? 0.0,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: _buildDropdownFormField(
                                    label: 'Unit *',
                                    value: _unit,
                                    items: _units,
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                        ? 'Please select a unit'
                                        : null,
                                    onSaved: (value) => _unit = value!,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isCalculatingSmartPrice
                                    ? null
                                    : _calculateSmartPrice,
                                icon: _isCalculatingSmartPrice
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.auto_awesome),
                                label: const Text('Calculate Smart Price'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.surfaceElevated,
                                  foregroundColor: AppColors.accentGreen,
                                  side: const BorderSide(
                                    color: AppColors.accentGreen,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Quantity
                            _buildTextFormField(
                              label: 'Quantity Available *',
                              hint: 'Enter quantity',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter quantity';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                              onSaved: (value) =>
                                  _quantity = double.parse(value!),
                            ),
                            const SizedBox(height: 16),
                            // Location
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: _buildTextFormField(
                                    label: 'Location *',
                                    hint: 'Enter location',
                                    controller: _locationController,
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                        ? 'Please enter location'
                                        : null,
                                    onSaved: (value) => _location = value!,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  height: 56, // Match text field height
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.accentGreen),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.my_location, color: AppColors.accentGreen),
                                    onPressed: _getCurrentLocation,
                                    tooltip: 'Get current location',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Toggle Switches
                            _buildSwitchListTile(
                              title: 'Organic Product',
                              value: _isOrganic,
                              onChanged: (value) =>
                                  setState(() => _isOrganic = value),
                              subtitle:
                                  'Certified organic produce fetches premium prices',
                            ),
                            const SizedBox(height: 8),
                            _buildSwitchListTile(
                              title: 'Available for Shipping',
                              value: _isAvailableForShipping,
                              onChanged: (value) => setState(
                                () => _isAvailableForShipping = value,
                              ),
                              subtitle:
                                  'Buyers from other locations can purchase',
                            ),
                            const SizedBox(height: 8),
                            _buildSwitchListTile(
                              title: 'Price Negotiable',
                              value: _isNegotiable,
                              onChanged: (value) =>
                                  setState(() => _isNegotiable = value),
                              subtitle: 'Allow buyers to negotiate the price',
                            ),
                            const SizedBox(height: 24),
                            // Submit Button
                            Center(
                              child: KisanButton(
                                text: 'Publish Listing',
                                isPrimary: true,
                                onPressed: _isLoading ? null : _submitListing,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Images *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _images.isEmpty
            ? Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.add_photo_alternate,
                    size: 48,
                    color: AppColors.accentGreen,
                  ),
                  onPressed: _pickImages,
                ),
              )
            : SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: MemoryImage(_images[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _removeImage(index),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
        const SizedBox(height: 8),
        if (_images.isNotEmpty)
          Text(
            '${_images.length} image${_images.length > 1 ? 's' : ''} selected',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }

  Widget _buildTextFormField({
    required String label,
    required String hint,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    int maxLines = 1,
    TextEditingController? controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.inputBorderUnfocused),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.inputBorderUnfocused),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.inputBorderFocused,
                width: 2.0,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          onSaved: onSaved,
          style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildDropdownFormField<T>({
    required String label,
    required T value,
    required List<T> items,
    String? Function(T?)? validator,
    void Function(T?)? onSaved,
    void Function(T?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelMedium),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              value: value,
              items: items
                  .map(
                    (item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(
                        item.toString(),
                        style: AppTypography.bodyLarge.copyWith(
                          color: item == value
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (onChanged != null) onChanged(value);
                if (onSaved != null) onSaved(value);
              },
              dropdownColor: AppColors.surface,
            ),
          ),
        ),
        if (validator != null && value != null && validator(value) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              validator(value)!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.dangerRed,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSwitchListTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(title, style: AppTypography.bodyLarge),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        trailing: Switch(
          value: value,
          activeColor: AppColors.accentGreen,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
