import 'dart:async';
import 'dart:developer';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  final InternetConnection _internetConnection = InternetConnection();
  late StreamSubscription<InternetStatus> _connectivitySubscription;
  bool isOffline = false;

  ConnectivityService() {
    _checkInternetConnectivity();
    _connectivitySubscription =
        _internetConnection.onStatusChange.listen(_updateConnectionStatus);
  }

  Future<void> _checkInternetConnectivity() async {
    bool hasInternet = await _internetConnection.hasInternetAccess;
    _updateConnectionStatus(
        hasInternet ? InternetStatus.connected : InternetStatus.disconnected);
  }

  void _updateConnectionStatus(InternetStatus status) {
    isOffline = status == InternetStatus.disconnected;
  }

  bool get isConnected => !isOffline;

  void dispose() {
    _connectivitySubscription.cancel();
  }
}
