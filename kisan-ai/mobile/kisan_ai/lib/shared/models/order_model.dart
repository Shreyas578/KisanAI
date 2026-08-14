class Order {
  final String id;
  final String buyerId;
  final String sellerId;
  final String listingId;
  final String productName;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final double totalAmount;
  final String currency;
  final DateTime orderDate;
  DateTime? deliveryDate;
  String status; // "placed", "confirmed", "processing", "shipped", "delivered", "cancelled"
  String paymentStatus; // "pending", "paid", "failed", "refunded"
  String paymentMethod; // "cod", "online", "wallet", "bank_transfer"
  String deliveryAddress;
  String trackingNumber; // For shipped orders
  String? notes; // Additional notes from buyer or seller
  List<String> statusHistory; // Timeline of status changes
  
  // For blockchain integration (optional)
  String? transactionHash; // Blockchain transaction hash
  String? contractAddress; // Smart contract address
  String? ipfsHash; // IPFS Pinata receipt hash

  // Display-only compatibility properties for marketplace order cards.
  final List<String> productImages;
  final String buyerName;
  final String buyerLocation;
  final String cancellationReason;

  Order({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.listingId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.totalAmount,
    required this.currency,
    required this.orderDate,
    this.deliveryDate,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.trackingNumber,
    this.notes,
    required this.statusHistory,
    this.transactionHash,
    this.contractAddress,
    this.ipfsHash,
    this.productImages = const [],
    this.buyerName = '',
    this.buyerLocation = '',
    this.cancellationReason = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'buyerId': buyerId,
        'sellerId': sellerId,
        'listingId': listingId,
        'productName': productName,
        'quantity': quantity,
        'unit': unit,
        'pricePerUnit': pricePerUnit,
        'totalAmount': totalAmount,
        'currency': currency,
        'orderDate': orderDate.toIso8601String(),
        'deliveryDate': deliveryDate?.toIso8601String(),
        'status': status,
        'paymentStatus': paymentStatus,
        'paymentMethod': paymentMethod,
        'deliveryAddress': deliveryAddress,
        'trackingNumber': trackingNumber,
        'notes': notes,
        'statusHistory': statusHistory,
        'transactionHash': transactionHash,
        'contractAddress': contractAddress,
        'ipfsHash': ipfsHash,
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        buyerId: json['buyerId'] ?? json['buyer_id'] ?? '',
        sellerId: json['sellerId'] ?? json['seller_id'] ?? '',
        listingId: json['listingId'] ?? json['listing_id'] ?? '',
        productName: json['productName'] ?? json['title'] ?? 'Unknown',
        quantity: _parseDouble(json['quantity'] ?? json['quantity_ordered']),
        unit: json['unit'] ?? 'unit',
        pricePerUnit: _parseDouble(json['pricePerUnit'] ?? (json['total_price'] != null && json['quantity_ordered'] != null ? (_parseDouble(json['total_price']) / (_parseDouble(json['quantity_ordered']) == 0 ? 1 : _parseDouble(json['quantity_ordered']))) : 0)),
        totalAmount: _parseDouble(json['totalAmount'] ?? json['total_price']),
        currency: json['currency'] ?? 'INR',
        orderDate: json['orderDate'] != null ? DateTime.parse(json['orderDate']) : (json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now()),
        deliveryDate: json['deliveryDate'] != null ? DateTime.parse(json['deliveryDate']) : null,
        status: json['status'] ?? 'pending',
        paymentStatus: json['paymentStatus'] ?? json['payment_status'] ?? 'pending',
        paymentMethod: json['paymentMethod'] ?? json['payment_method'] ?? 'upi',
        deliveryAddress: json['deliveryAddress'] ?? '',
        trackingNumber: json['trackingNumber'] ?? '',
        notes: json['notes'],
        statusHistory: List<String>.from(json['statusHistory'] ?? []),
        transactionHash: json['tx_hash'] ?? json['transactionHash'],
        contractAddress: json['contractAddress'],
        ipfsHash: json['ipfs_hash'] ?? json['ipfsHash'],
      );

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
