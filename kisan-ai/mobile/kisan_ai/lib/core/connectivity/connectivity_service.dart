import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

/// Connectivity Service - Detects online/offline status
///
/// Monitors network connectivity and provides status stream
/// for offline mode implementation

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();

  factory ConnectivityService() {
    return _instance;
  }

  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();

  late StreamSubscription<ConnectivityResult> _subscription;
  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;

  /// Stream of connectivity status changes
  Stream<ConnectivityStatus> get onStatusChange => _statusController.stream;

  /// Current connectivity status
  ConnectivityStatus get currentStatus => _currentStatus;

  /// Initialize connectivity service
  void initialize() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      (result) => _updateStatus(result),
    );

    // Check initial status
    _checkInitialStatus();
  }

  /// Check initial connectivity status
  Future<void> _checkInitialStatus() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateStatus(result);
    } catch (e) {
      print('Error checking connectivity: $e');
      _currentStatus = ConnectivityStatus.unknown;
      _statusController.add(_currentStatus);
    }
  }

  /// Update status based on connectivity result
  Future<void> _updateStatus(ConnectivityResult result) async {
    ConnectivityStatus newStatus = ConnectivityStatus.offline;

    switch (result) {
      case ConnectivityResult.mobile:
        newStatus = ConnectivityStatus.mobile;
        break;
      case ConnectivityResult.wifi:
        newStatus = ConnectivityStatus.wifi;
        break;
      case ConnectivityResult.ethernet:
        newStatus = ConnectivityStatus.ethernet;
        break;
      case ConnectivityResult.none:
        newStatus = ConnectivityStatus.offline;
        break;
      case ConnectivityResult.vpn:
      case ConnectivityResult.other:
        newStatus = ConnectivityStatus.other;
        break;
      case ConnectivityResult.bluetooth:
        newStatus = ConnectivityStatus.other;
        break;
    }

    if (newStatus != _currentStatus) {
      _currentStatus = newStatus;
      _statusController.add(_currentStatus);
    }
  }

  /// Check if device has internet connectivity
  /// Does actual ping to verify real connectivity
  Future<bool> isOnline() async {
    try {
      // First check if device has connection
      final result = await _connectivity.checkConnectivity();
      if (result == ConnectivityResult.none) return false;

      // Do a real ping to backend
      final response = await http
          .get(Uri.parse('http://localhost:3000/'))
          .timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Check if device is definitely offline
  Future<bool> isOffline() async {
    return !(await isOnline());
  }

  /// Get connection type as string
  String getConnectionTypeString(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.wifi:
        return 'WiFi';
      case ConnectivityStatus.mobile:
        return 'Mobile';
      case ConnectivityStatus.ethernet:
        return 'Ethernet';
      case ConnectivityStatus.offline:
        return 'Offline';
      default:
        return 'Unknown';
    }
  }

  /// Dispose service
  void dispose() {
    _subscription.cancel();
    _statusController.close();
  }
}

/// Connectivity status enum
enum ConnectivityStatus { wifi, mobile, ethernet, offline, other, unknown }
