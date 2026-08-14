class MarketPrice {
  final String id;
  final String commodity; // e.g., "Tomato", "Onion", "Potato"
  final String variety; // Optional variety specification
  final String marketName; // Name of the mandi/market
  final String state;
  final String district;
  final DateTime priceDate; // Date of the price data
  final double minPrice; // Minimum price in Rs/quintal
  final double maxPrice; // Maximum price in Rs/quintal
  final double modalPrice; // Most frequent price in Rs/quintal
  final String unit; // Usually "quintal" (100 kg)
  final String priceTrend; // "increasing", "decreasing", "stable"
  final String grade; // Quality grade if applicable
  final String source; // Data source (e.g., "AGMARKNET", "state_agri_board")

  MarketPrice({
    required this.id,
    required this.commodity,
    this.variety = '',
    required this.marketName,
    required this.state,
    required this.district,
    required this.priceDate,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    required this.unit,
    required this.priceTrend,
    required this.grade,
    required this.source,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'commodity': commodity,
        'variety': variety,
        'marketName': marketName,
        'state': state,
        'district': district,
        'priceDate': priceDate.toIso8601String(),
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'modalPrice': modalPrice,
        'unit': unit,
        'priceTrend': priceTrend,
        'grade': grade,
        'source': source,
      };

  factory MarketPrice.fromJson(Map<String, dynamic> json) => MarketPrice(
        id: json['id'],
        commodity: json['commodity'],
        variety: json['variety'] ?? '',
        marketName: json['marketName'],
        state: json['state'],
        district: json['district'],
        priceDate: DateTime.parse(json['priceDate']),
        minPrice: json['minPrice'],
        maxPrice: json['maxPrice'],
        modalPrice: json['modalPrice'],
        unit: json['unit'],
        priceTrend: json['priceTrend'],
        grade: json['grade'],
        source: json['source'],
      );
}
