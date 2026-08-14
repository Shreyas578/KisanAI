import 'dart:convert';

class MarketplaceListing {
  final String id;
  final String sellerId;
  final String sellerName;
  final String title;
  final String description;
  final String category; // "produce", "inputs", "equipment", "services"
  final String
  subcategory; // e.g., if produce: "vegetables", "fruits", "grains"
  final String productName; // Specific product name
  final String variety; // Variety of the product
  final double quantity;
  final String unit; // "kg", "quintal", "tons", "liters", "pieces", etc.
  final double pricePerUnit;
  final String currency; // Usually "INR"
  final bool isNegotiable;
  final String location; // Could be city, district, or coordinates
  final String state;
  final String district;
  final List<String> images; // URLs of product images
  final String
  qualityGrade; // "A", "B", "C" or "premium", "standard", "economy"
  bool isVerified; // Whether the listing is verified by platform
  DateTime postedAt;
  DateTime? expiresAt;
  String status; // "active", "sold", "expired", "inactive"
  String? contactNumber; // Optional contact number for seller
  bool isFeatured; // Whether listing is featured/promoted
  final bool isOrganic;
  final int totalReviews;
  final double averageRating;
  final int views;
  final int inquiries;
  final Map<String, dynamic> additionalInfo;

  MarketplaceListing({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.title,
    required this.description,
    required this.category,
    this.subcategory = '',
    String? productName,
    this.variety = '',
    double? quantity,
    required this.unit,
    double? pricePerUnit,
    this.currency = 'INR',
    this.isNegotiable = false,
    required this.location,
    this.state = '',
    this.district = '',
    List<String>? images,
    this.qualityGrade = 'standard',
    required this.isVerified,
    DateTime? postedAt,
    this.expiresAt,
    this.status = 'active',
    this.contactNumber,
    this.isFeatured = false,
    bool? isOrganic,
    int? totalReviews,
    double? averageRating,
    this.views = 0,
    this.inquiries = 0,
    Map<String, dynamic>? additionalInfo,
    double? price,
    double? quantityAvailable,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : productName = productName ?? title,
       quantity = quantity ?? quantityAvailable ?? 0,
       pricePerUnit = pricePerUnit ?? price ?? 0,
       images =
           images ?? (imageUrl == null || imageUrl.isEmpty ? [] : [imageUrl]),
       postedAt = postedAt ?? createdAt ?? DateTime.now(),
       isOrganic = isOrganic ?? false,
       totalReviews = totalReviews ?? 0,
       averageRating = averageRating ?? 0,
       additionalInfo = additionalInfo ?? const {};

  double get price => pricePerUnit;
  double get quantityAvailable => quantity;
  String get imageUrl => images.isEmpty ? '' : images.first;
  bool get isActive => status == 'active';

  Map<String, dynamic> toJson() => {
    'id': id,
    'sellerId': sellerId,
    'sellerName': sellerName,
    'title': title,
    'description': description,
    'category': category,
    'subcategory': subcategory,
    'productName': productName,
    'variety': variety,
    'quantity': quantity,
    'unit': unit,
    'pricePerUnit': pricePerUnit,
    'currency': currency,
    'isNegotiable': isNegotiable,
    'location': location,
    'state': state,
    'district': district,
    'images': images,
    'qualityGrade': qualityGrade,
    'isVerified': isVerified,
    'postedAt': postedAt.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'status': status,
    'contactNumber': contactNumber,
    'isFeatured': isFeatured,
  };

  factory MarketplaceListing.fromJson(Map<String, dynamic> json) {
    // Safely parse JSON strings for images if coming from DB directly
    List<String> parsedImages = [];
    if (json['images'] != null) {
      if (json['images'] is String) {
        try {
          final decoded = jsonDecode(json['images']);
          if (decoded is List) {
            parsedImages = List<String>.from(decoded);
          }
        } catch (_) {}
      } else if (json['images'] is List) {
        parsedImages = List<String>.from(json['images']);
      }
    }

    // Safely parse location
    String loc = 'Unknown Location';
    if (json['location'] != null) {
      if (json['location'] is String) {
        try {
          final decoded = jsonDecode(json['location']);
          loc = decoded['address'] ?? decoded['city'] ?? decoded.toString();
        } catch (_) {
          loc = json['location'];
        }
      } else if (json['location'] is Map) {
        loc = json['location']['address'] ?? json['location']['city'] ?? 'Unknown Location';
      }
    }

    return MarketplaceListing(
      id: json['id']?.toString() ?? '',
      sellerId: json['sellerId'] ?? json['seller_id'] ?? '',
      sellerName: json['sellerName'] ?? json['seller_name'] ?? 'Unknown Seller',
      title: json['title'] ?? 'Untitled',
      description: json['description'] ?? '',
      category: json['category'] ?? 'produce',
      subcategory: json['subcategory'] ?? '',
      productName: json['productName'] ?? json['product_name'],
      variety: json['variety'] ?? '',
      quantity: json['quantity'] != null ? double.tryParse(json['quantity'].toString()) : 0,
      unit: json['unit'] ?? 'kg',
      pricePerUnit: json['pricePerUnit'] != null ? double.tryParse(json['pricePerUnit'].toString()) : (json['price_per_unit'] != null ? double.tryParse(json['price_per_unit'].toString()) : 0),
      currency: json['currency'] ?? 'INR',
      isNegotiable: json['isNegotiable'] ?? json['is_negotiable'] == 1 || json['is_negotiable'] == true,
      location: loc,
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      images: parsedImages,
      qualityGrade: json['qualityGrade'] ?? json['quality_grade'] ?? 'standard',
      isVerified: json['isVerified'] ?? json['is_verified'] == 1 || json['is_verified'] == true,
      postedAt: json['postedAt'] != null ? DateTime.parse(json['postedAt']) : (json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now()),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      status: json['status'] ?? 'active',
      contactNumber: json['contactNumber'] ?? json['contact_number'],
      isFeatured: json['isFeatured'] ?? json['is_featured'] == 1 || json['is_featured'] == true,
    );
  }
}
