import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ConnectivityProvider with ChangeNotifier {
  late ConnectivityResult _connectivityResult;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _hasInternet = false;

  ConnectivityProvider() {
    _connectivityResult = ConnectivityResult.none;
    _checkInitialConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      _updateConnectivityStatus(result.first);
    });
  }

  ConnectivityResult get connectivityResult => _connectivityResult;
  bool get hasInternet => _hasInternet;

  Future<void> _checkInitialConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectivityStatus(result.first);
  }

  void _updateConnectivityStatus(ConnectivityResult result) {
    _connectivityResult = result;
    _hasInternet = result != ConnectivityResult.none;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
