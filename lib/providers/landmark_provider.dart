import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/landmark.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class LandmarkProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService.instance;

  List<Landmark> _landmarks = [];
  bool _isLoading = false;
  String? _error;
  bool _isOnline = true;

  List<Landmark> get landmarks => List.unmodifiable(_landmarks);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOnline => _isOnline;

  LandmarkProvider() {
    print('>>> LandmarkProvider initialized');
    _checkConnectivity();
    _initLandmarks();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;
    print('>>> Connectivity: ${_isOnline ? "Online" : "Offline"}');

    Connectivity().onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;
      print('>>> Connectivity changed: ${_isOnline ? "Online" : "Offline"}');

      if (_isOnline && !wasOnline) {
        print('>>> Connection restored, fetching landmarks');
        fetchLandmarks();
      }
      notifyListeners();
    });
  }

  Future<void> _initLandmarks() async {
    print('>>> Initializing landmarks');
    await fetchLandmarks();
  }

  Future<void> fetchLandmarks() async {
    print('');
    print('>>> ========================================');
    print('>>> FETCH LANDMARKS CALLED');
    print('>>> ========================================');
    print('>>> Current landmarks count: ${_landmarks.length}');
    print('>>> Is loading: $_isLoading');
    print('>>> Is online: $_isOnline');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_isOnline) {
        print('>>> Fetching from API...');
        final apiLandmarks = await _apiService.fetchLandmarks();
        print('>>> API returned ${apiLandmarks.length} landmarks');

        // Update state immediately
        _landmarks = List.from(apiLandmarks);
        print('>>> State updated with ${_landmarks.length} landmarks');

        // Notify listeners before database operation
        _isLoading = false;
        notifyListeners();
        print('>>> UI notified');

        // Save to database in background
        try {
          print('>>> Saving to database...');
          await _dbService.clearAllLandmarks();
          for (var landmark in apiLandmarks) {
            await _dbService.insertLandmark(landmark);
          }
          print('>>> Database saved successfully');
        } catch (dbError) {
          print('>>> Database save error (non-critical): $dbError');
        }
      } else {
        print('>>> Loading from database (offline)...');
        _landmarks = await _dbService.getAllLandmarks();
        print('>>> Loaded ${_landmarks.length} landmarks from database');
        _isLoading = false;
        notifyListeners();
      }

      print('>>> Fetch completed successfully');
      print('>>> Final landmark count: ${_landmarks.length}');
    } catch (e, stackTrace) {
      print('>>> ========================================');
      print('>>> FETCH ERROR');
      print('>>> ========================================');
      print('>>> Error: $e');
      print('>>> Stack trace: $stackTrace');

      _error = e.toString();

      // Try to load from database as fallback
      try {
        print('>>> Loading from database as fallback...');
        _landmarks = await _dbService.getAllLandmarks();
        print('>>> Loaded ${_landmarks.length} landmarks from database (fallback)');
      } catch (dbError) {
        print('>>> Database fallback also failed: $dbError');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
      print('>>> Fetch operation complete');
      print('>>> ========================================');
      print('');
    }
  }

  Future<bool> createLandmark({
    required String title,
    required double lat,
    required double lon,
    File? imageFile,
  }) async {
    print('');
    print('>>> ========================================');
    print('>>> CREATE LANDMARK');
    print('>>> ========================================');

    if (!_isOnline) {
      _error = 'No internet connection';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('>>> Creating landmark via API...');
      await _apiService.createLandmark(
        title: title,
        lat: lat,
        lon: lon,
        imageFile: imageFile,
      );

      print('>>> Create successful, waiting 2 seconds...');
      await Future.delayed(const Duration(seconds: 2));

      print('>>> Fetching updated list...');
      await fetchLandmarks();

      return true;
    } catch (e) {
      print('>>> Create error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateLandmark({
    required int id,
    required String title,
    required double lat,
    required double lon,
    File? imageFile,
  }) async {
    print('');
    print('>>> ========================================');
    print('>>> UPDATE LANDMARK ID: $id');
    print('>>> ========================================');

    if (!_isOnline) {
      _error = 'No internet connection';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('>>> Updating landmark via API...');
      await _apiService.updateLandmark(
        id: id,
        title: title,
        lat: lat,
        lon: lon,
        imageFile: imageFile,
      );

      print('>>> Update successful, waiting 2 seconds...');
      await Future.delayed(const Duration(seconds: 2));

      print('>>> Fetching updated list...');
      await fetchLandmarks();

      return true;
    } catch (e) {
      print('>>> Update error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLandmark(int id) async {
    print('');
    print('>>> ========================================');
    print('>>> DELETE LANDMARK ID: $id');
    print('>>> ========================================');

    if (!_isOnline) {
      _error = 'No internet connection';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('>>> Deleting landmark via API...');
      await _apiService.deleteLandmark(id);

      print('>>> Delete successful, waiting 2 seconds...');
      await Future.delayed(const Duration(seconds: 2));

      print('>>> Fetching updated list...');
      await fetchLandmarks();

      return true;
    } catch (e) {
      print('>>> Delete error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> forceRefresh() async {
    print('>>> Force refresh requested');
    await fetchLandmarks();
  }
}