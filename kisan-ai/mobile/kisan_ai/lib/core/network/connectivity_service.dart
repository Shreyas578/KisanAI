import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityServiceProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();

  // Initial check - now returns List<ConnectivityResult>
  final initialResult = await connectivity.checkConnectivity();
  final isConnected = initialResult.contains(ConnectivityResult.none) == false;
  yield isConnected;

  // Listen to changes - now returns List<ConnectivityResult>
  await for (final results in connectivity.onConnectivityChanged) {
    final connected = results.contains(ConnectivityResult.none) == false;
    yield connected;
  }
});
