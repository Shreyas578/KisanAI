import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Search result model
class SearchResult {
  final String id;
  final String name;
  final String description;
  final double price;
  final String seller;
  final String category;
  final double rating;
  final String imageUrl;

  SearchResult({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.seller,
    required this.category,
    required this.rating,
    required this.imageUrl,
  });
}

/// Search state
class SearchState {
  final List<SearchResult> results;
  final List<String> searchHistory;
  final bool isLoading;
  final String? error;
  final String currentQuery;
  final String sortBy;
  final String? selectedCategory;

  SearchState({
    required this.results,
    required this.searchHistory,
    required this.isLoading,
    this.error,
    required this.currentQuery,
    required this.sortBy,
    this.selectedCategory,
  });

  SearchState copyWith({
    List<SearchResult>? results,
    List<String>? searchHistory,
    bool? isLoading,
    String? error,
    String? currentQuery,
    String? sortBy,
    String? selectedCategory,
  }) {
    return SearchState(
      results: results ?? this.results,
      searchHistory: searchHistory ?? this.searchHistory,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentQuery: currentQuery ?? this.currentQuery,
      sortBy: sortBy ?? this.sortBy,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

/// Sample marketplace products for search
final sampleProducts = [
  SearchResult(
    id: '1',
    name: 'Organic Tomato',
    description: 'Fresh organic tomatoes from local farm',
    price: 45.0,
    seller: 'Green Valley Farms',
    category: 'Vegetables',
    rating: 4.8,
    imageUrl: 'https://via.placeholder.com/200?text=Tomato',
  ),
  SearchResult(
    id: '2',
    name: 'Basmati Rice',
    description: 'Premium basmati rice 1kg',
    price: 120.0,
    seller: 'Rice King',
    category: 'Grains',
    rating: 4.5,
    imageUrl: 'https://via.placeholder.com/200?text=Rice',
  ),
  SearchResult(
    id: '3',
    name: 'Wheat Flour',
    description: 'Pure wheat flour for cooking',
    price: 35.0,
    seller: 'Mill House',
    category: 'Grains',
    rating: 4.3,
    imageUrl: 'https://via.placeholder.com/200?text=Flour',
  ),
  SearchResult(
    id: '4',
    name: 'Fresh Milk',
    description: 'Fresh dairy milk 1 liter',
    price: 50.0,
    seller: 'Dairy Fresh',
    category: 'Dairy',
    rating: 4.9,
    imageUrl: 'https://via.placeholder.com/200?text=Milk',
  ),
  SearchResult(
    id: '5',
    name: 'Onion 1kg',
    description: 'Fresh onions 1kg pack',
    price: 30.0,
    seller: 'Veggie Vendor',
    category: 'Vegetables',
    rating: 4.2,
    imageUrl: 'https://via.placeholder.com/200?text=Onion',
  ),
  SearchResult(
    id: '6',
    name: 'Potato Sack',
    description: 'Fresh potatoes 5kg sack',
    price: 85.0,
    seller: 'Potato Palace',
    category: 'Vegetables',
    rating: 4.6,
    imageUrl: 'https://via.placeholder.com/200?text=Potato',
  ),
  SearchResult(
    id: '7',
    name: 'Sugar (1kg)',
    description: 'Pure white sugar 1kg',
    price: 45.0,
    seller: 'Sweet Supplies',
    category: 'Pantry',
    rating: 4.4,
    imageUrl: 'https://via.placeholder.com/200?text=Sugar',
  ),
  SearchResult(
    id: '8',
    name: 'Ghee',
    description: 'Pure desi ghee 500ml',
    price: 280.0,
    seller: 'Dairy Delights',
    category: 'Dairy',
    rating: 4.7,
    imageUrl: 'https://via.placeholder.com/200?text=Ghee',
  ),
  SearchResult(
    id: '9',
    name: 'Chicken (1kg)',
    description: 'Fresh chicken 1kg pack',
    price: 180.0,
    seller: 'Meat Master',
    category: 'Proteins',
    rating: 4.5,
    imageUrl: 'https://via.placeholder.com/200?text=Chicken',
  ),
  SearchResult(
    id: '10',
    name: 'Honey (500ml)',
    description: 'Pure raw honey 500ml',
    price: 250.0,
    seller: 'Bee Farms',
    category: 'Pantry',
    rating: 4.9,
    imageUrl: 'https://via.placeholder.com/200?text=Honey',
  ),
  SearchResult(
    id: '11',
    name: 'Green Chili',
    description: 'Fresh green chili 500g',
    price: 40.0,
    seller: 'Spice Master',
    category: 'Vegetables',
    rating: 4.3,
    imageUrl: 'https://via.placeholder.com/200?text=Chili',
  ),
  SearchResult(
    id: '12',
    name: 'Garlic Bulbs',
    description: 'Fresh garlic bulbs 500g',
    price: 55.0,
    seller: 'Garlic House',
    category: 'Vegetables',
    rating: 4.6,
    imageUrl: 'https://via.placeholder.com/200?text=Garlic',
  ),
];

/// Search notifier
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier()
    : super(
        SearchState(
          results: [],
          searchHistory: [],
          isLoading: false,
          currentQuery: '',
          sortBy: 'name',
        ),
      );

  /// Perform search
  void search(String query) {
    if (query.isEmpty) {
      state = state.copyWith(results: [], currentQuery: '', error: null);
      return;
    }

    state = state.copyWith(isLoading: true, currentQuery: query);

    try {
      // Filter products
      final filtered = sampleProducts
          .where(
            (product) =>
                product.name.toLowerCase().contains(query.toLowerCase()) ||
                product.description.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                product.category.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();

      // Sort results
      _sortResults(filtered);

      // Add to history
      final history = [
        query,
        ...state.searchHistory,
      ].toSet().toList().take(10).toList();

      state = state.copyWith(
        results: filtered,
        isLoading: false,
        error: filtered.isEmpty ? 'No products found' : null,
        searchHistory: history,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Sort results
  void _sortResults(List<SearchResult> results) {
    switch (state.sortBy) {
      case 'price_low':
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'name':
      default:
        results.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
  }

  /// Change sort
  void changeSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
    // Re-search with new sort
    if (state.currentQuery.isNotEmpty) {
      search(state.currentQuery);
    }
  }

  /// Filter by category
  void filterByCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// Clear search history
  void clearHistory() {
    state = state.copyWith(searchHistory: []);
  }

  /// Get search history
  List<String> getHistory() => state.searchHistory;
}

/// Search provider
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((
  ref,
) {
  return SearchNotifier();
});

/// Search results provider
final searchResultsProvider = Provider<List<SearchResult>>((ref) {
  final searchState = ref.watch(searchProvider);
  return searchState.results;
});

/// Search history provider
final searchHistoryProvider = Provider<List<String>>((ref) {
  final searchState = ref.watch(searchProvider);
  return searchState.searchHistory;
});
