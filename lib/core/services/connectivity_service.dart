import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service that monitors network connectivity.
/// Uses connectivity_plus for status changes, plus an actual HTTP
/// ping to confirm real internet access (not just being on a LAN).
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isOnline = false;

  bool get isOnline => _isOnline;

  /// Emits true when online, false when offline.
  Stream<bool> get onConnectivityChanged => _controller.stream;

  /// Initialize and start listening for connectivity changes.
  Future<void> initialize() async {
    // Check initial state
    _isOnline = await checkConnection();

    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) async {
        final wasOnline = _isOnline;
        // connectivity_plus gives network type — we still do a real ping
        if (results.contains(ConnectivityResult.none)) {
          _isOnline = false;
        } else {
          _isOnline = await _ping();
        }
        if (wasOnline != _isOnline) {
          _controller.add(_isOnline);
        }
      },
    );
  }

  /// Perform an actual network reachability check.
  Future<bool> checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    if (results.contains(ConnectivityResult.none)) return false;
    return _ping();
  }

  /// Ping a reliable host to confirm real internet access.
  Future<bool> _ping() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
