# Phase 3 Completion Plan: Remaining Service Layers and UI Integration

## ✅ What Has Been Completed
1. **Data Models**: All 16+ agricultural domain models created in `lib/shared/models/`
2. **Offline ML**: TensorFlow Lite disease detection integrated and working
3. **Core Services**: Weather, Market Price, and Farm Report services implemented
4. **State Management**: Riverpod providers for completed services
5. **Key UI Updates**: Weather and Disease Detection screens using real data

## 🔧 Remaining Service Layers to Create (Following Established Patterns)

Each service should follow this template (based on `weather_service.dart`):

### 1. Marketplace Service (`lib/features/marketplace/services/marketplace_service.dart`)
```dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/constants/api_constants.dart';
import 'package:kisan_ai/core/network/api_client.dart';
import 'package:kisan_ai/shared/models/marketplace_listing_model.dart';

class MarketplaceService {
  final ApiClient _apiClient;

  MarketplaceService(this._apiClient);

  // Get listings with filters
  Future<List<MarketplaceListing>> getListings({
    String? category,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    String? location,
    bool? verifiedOnly,
  }) async {
    // Implementation following market_price_service pattern
  }

  // Create a new listing
  Future<MarketplaceListing> createListing(MarketplaceListing listing) async {
    // POST request to ApiConstants.marketplaceCreateListing
  }

  // Get listing by ID
  Future<MarketplaceListing> getListingById(String listingId) async {
    // GET request to '${ApiConstants.marketplaceListings}/$listingId'
  }

  // Update listing
  Future<MarketplaceListing> updateListing(String listingId, MarketplaceListing listing) async {
    // PUT/PATCH request
  }

  // Delete listing
  Future<bool> deleteListing(String listingId) async {
    // DELETE request
  }

  // Get user's listings
  Future<List<MarketplaceListing>> getUserListings(String userId) async {
    // GET request with user_id filter
  }

  // Get categories
  Future<List<String>> getCategories() async {
    // GET request to '${ApiConstants.marketplaceListings}/categories'
  }
}
```

### 2. Order Service (`lib/features/order/services/order_service.dart`)
```dart
class OrderService {
  final ApiClient _apiClient;

  OrderService(this._apiClient);

  // Get orders with filters
  Future<List<Order>> getOrders({
    String? status, // buying, selling, all
    String? type, // products, inputs
    int? limit,
    int? offset,
  }) async { /* ... */ }

  // Place new order
  Future<Order> placeOrder(Order order) async { /* ... */ }

  // Get order by ID
  Future<Order> getOrderById(String orderId) async { /* ... */ }

  // Update order status
  Future<Order> updateOrderStatus(String orderId, String status) async { /* ... */ }

  // Get order history
  Future<List<Order>> getOrderHistory(String userId, {int limit = 10}) async { /* ... */ }
}
```

### 3. ChatBot Service (`lib/features/chatbot/services/chatbot_service.dart`)
```dart
class ChatbotService {
  final ApiClient _apiClient;

  ChatbotService(this._apiClient);

  // Send message
  Future<ChatMessage> sendMessage(ChatMessage message) async { /* ... */ }

  // Get conversation messages
  Future<List<ChatMessage>> getConversationMessages(String conversationId, {int limit = 50}) async { /* ... */ }

  // Get conversations
  Future<List<ChatConversation>> getConversations(String userId) async { /* ... */ }

  // Start new conversation
  Future<ChatConversation> startConversation(String userId, String? agentId) async { /* ... */ }

  // Get bot config
  Future<ChatBotConfig> getBotConfig(String botId) async { /* ... */ }

  // Upload media (for image/audio messages)
  Future<String> uploadMedia(Uint8List fileBytes, String fileName) async { /* ... */ }
}
```

### 4. Government Scheme Service (`lib/features/government_scheme/services/government_scheme_service.dart`)
```dart
class GovernmentSchemeService {
  final ApiClient _apiClient;

  GovernmentSchemeService(this._apiClient);

  // Get schemes with filters
  Future<List<GovernmentScheme>> getSchemes({
    String? schemeType,
    String? cropType,
    String? farmerType,
    bool? activeOnly,
  }) async { /* ... */ }

  // Get scheme by ID
  Future<GovernmentScheme> getSchemeById(String schemeId) async { /* ... */ }

  // Apply for scheme
  Future<FarmerSchemeApplication> applyForScheme(FarmerSchemeApplication application) async { /* ... */ }

  // Get user's applications
  Future<List<FarmerSchemeApplication>> getUserApplications(String farmerId) async { /* ... */ }

  // Get application by ID
  Future<FarmerSchemeApplication> getApplicationById(String applicationId) async { /* ... */ }

  // Update application status (for officials)
  Future<FarmerSchemeApplication> updateApplicationStatus(
    String applicationId, 
    String status, {
    String? approvalReference,
    String? remarks,
  }) async { /* ... */ }
}
```

### 5. Input Management Services (Irrigation, Fertilization, Pesticide)
These would follow similar patterns with CRUD operations for schedules and executions.

## 📱 Corresponding Provider Files

For each service, create a provider file following the weather/market provider pattern:

```dart
// Example: marketplace_state/marketplace_provider.dart
final marketplaceApiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient('https://api.kisanai.com');
});

final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  final apiClient = ref.read(marketplaceApiClientProvider);
  return MarketplaceService(apiClient);
});

// Family providers for filtered data
final marketplaceListingsProvider = FutureProvider.family<List<MarketplaceListing>, Map<String, dynamic>>((ref, filters) {
  final service = ref.read(marketplaceServiceProvider);
  return service.getListings(
    category: filters['category'] as String?,
    searchQuery: filters['searchQuery'] as String?,
    minPrice: filters['minPrice'] as double?,
    maxPrice: filters['maxPrice'] as double?,
    location: filters['location'] as String?,
    verifiedOnly: filters['verifiedOnly'] as bool?,
  );
});

// Other providers...
final userListingsProvider = FutureProvider.family<List<MarketplaceListing>, String>((ref, userId) {
  return ref.read(marketplaceServiceProvider).getUserListings(userId);
});
```

## 🖥️ UI Screen Updates Needed

Update these screens to use real services instead of mocks:

1. **Marketplace Screens** (`lib/features/marketplace/screens/`)
   - Replace mock listings with real service calls
   - Implement search/filtering
   - Add create/listing flow

2. **Order Screens** (`lib/features/order/screens/`)
   - Connect to real order service
   - Show actual order history
   - Implement order placement flow

3. **ChatBot Screens** (`lib/features/chatbot/screens/`)
   - Replace mock conversations with real service
   - Implement real-time messaging
   - Add voice/image message support

4. **Government Scheme Screens** 
   - Connect to scheme service
   - Implement browsing/searching
   - Add application flow

5. **Input Management Screens** 
   - Irrigation/Fertilization/Pesticide schedules
   - Connect to respective services
   - Show calendar/views

## ⚡ Rapid Implementation Strategy

Given time constraints, follow this approach:

### Step 1: Create Service Templates (30-45 minutes)
1. Copy `weather_service.dart` as template
2. Modify endpoint URLs and method signatures for each feature
3. Adjust request/response handling based on API contracts
4. Keep error handling and logging patterns consistent

### Step 2: Create Provider Files (20-30 minutes)
1. Copy `weather_provider.dart` as template
2. Update provider names and service references
3. Maintain identical provider patterns (singleton apiClient, service provider, family providers)
4. Add any feature-specific providers as needed

### Step 3: Update UI Screens (60-90 minutes per screen)
1. Convert to `ConsumerStatefulWidget` or `ConsumerWidget`
2. Replace mock data with `ref.watch(provider)` calls
3. Implement proper loading/error/shimmer states (copy from weather_screen)
4. Connect UI interactions to service methods
5. Test basic functionality

### Step 4: Integration Verification (30 minutes)
1. Verify navigation between screens works
2. Check data flows correctly
3. Ensure error handling is graceful
4. Confirm offline capabilities still work where appropriate

## 🎯 Time-Efficient Completion Approach

Instead of building everything from scratch, leverage the exact patterns already established:

1. **Service Layer**: 90% copy-paste from existing services with endpoint/method changes
2. **Provider Layer**: 95% copy-paste from existing providers with name changes  
3. **UI Layer**: 70% copy-paste from weather_screen with data binding changes

Example time estimates per feature:
- Service file: 15-20 minutes
- Provider file: 10-15 minutes  
- Main screen update: 30-45 minutes
- Total per feature: ~60-80 minutes

With 5-6 remaining major features, estimated 5-8 hours of focused work.

## 📋 Immediate Next Actions

1. **Create marketplace service** (start with most complex UI interaction)
2. **Create marketplace provider** 
3. **Update marketplace main screen**
4. **Create order service**
5. **Create order provider**
6. **Update order history screen**
7. **Continue with remaining features in priority order**

## 🔄 Reuse Existing Patterns

All remaining work should strictly follow these established patterns:
- Service classes with `ApiClient` dependency injection
- Consistent error handling converting `DioException` to app-specific exceptions
- Provider files with `apiClientProvider` → `serviceProvider` → feature-specific providers
- UI screens using `ConsumerStatefulWidget` with `ref.watch()` and `.when()` handlers
- Loading shimmers and error widgets copied from working implementations
- Model classes already exist - just need to use them

By rigidly following these copy-modify patterns, the remaining Phase 3 work can be completed efficiently and consistently with what's already built.

The foundation is solid - now it's about systematic application of the established architectural patterns to complete the remaining features.