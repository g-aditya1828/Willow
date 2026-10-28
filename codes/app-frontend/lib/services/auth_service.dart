import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final int id;
  final String username;
  final String email;
  final int scanCount;
  final int favoriteCount;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.scanCount = 0,
    this.favoriteCount = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      scanCount: json['scan_count'] is int ? json['scan_count'] : 0,
      favoriteCount: json['favorite_count'] is int ? json['favorite_count'] : 0,
    );
  }
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _tokenKey = "willow_auth_token";
  static const String _userKey = "willow_user_data";

  // Base API URL
  static const String baseUrl = "http://127.0.0.1:5000";

  String? _token;
  UserProfile? _currentUser;
  bool _initialized = false;
  bool _isGuest = false;

  bool get isAuthenticated => (_token != null && _currentUser != null) || _isGuest;
  bool get isGuest => _isGuest;
  String? get token => _token;
  UserProfile? get currentUser => _currentUser;
  bool get isInitialized => _initialized;

  void continueAsGuest() {
    _isGuest = true;
    _currentUser = UserProfile(
      id: 0,
      username: 'Alex',
      email: 'alex@willow.app',
      scanCount: 4,
      favoriteCount: 2,
    );
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
      final userStr = prefs.getString(_userKey);
      if (userStr != null) {
        _currentUser = UserProfile.fromJson(jsonDecode(userStr));
      }
      if (_token != null) {
        await refreshProfile();
      }
    } catch (e) {
      debugPrint("Auth init error: $e");
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/api/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username.trim(),
          "email": email.trim(),
          "password": password,
        }),
      );

      final body = jsonDecode(res.body);
      if (res.statusCode == 201) {
        _token = body['token'];
        _currentUser = UserProfile.fromJson(body['user']);
        await _saveSession();
        notifyListeners();
        return {"success": true, "message": body['message']};
      } else {
        return {"success": false, "error": body['error'] ?? "Registration failed"};
      }
    } catch (e) {
      return {"success": false, "error": "Cannot connect to Willow server: $e"};
    }
  }

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/api/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "identifier": identifier.trim(),
          "password": password,
        }),
      );

      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        _token = body['token'];
        _currentUser = UserProfile.fromJson(body['user']);
        await _saveSession();
        // Notify immediately so UI navigates to home — then refresh in background
        notifyListeners();
        // Background refresh (don't await — don't block navigation)
        refreshProfile().catchError((_) {});
        return {"success": true, "message": body['message'] ?? "Login successful"};
      } else {
        return {"success": false, "error": body['error'] ?? "Login failed"};
      }
    } catch (e) {
      return {"success": false, "error": "Cannot connect to Willow server. Is the backend running?"};
    }
  }

  Future<void> refreshProfile() async {
    if (_token == null) return;
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/api/auth/me"),
        headers: {
          "Authorization": "Bearer $_token",
          "Content-Type": "application/json",
        },
      ).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        _currentUser = UserProfile.fromJson(body['user']);
        await _saveSession();
        notifyListeners();
      } else if (res.statusCode == 401) {
        // Token is invalid/expired — force logout
        await logout();
      }
      // Any other status (500, 503, etc.) — keep session, silent fail
    } catch (e) {
      // Network error or timeout — keep session intact, don't logout
      debugPrint("Refresh profile error (non-fatal): $e");
    }
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    _isGuest = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    notifyListeners();
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) {
      await prefs.setString(_tokenKey, _token!);
    }
    if (_currentUser != null) {
      await prefs.setString(_userKey, jsonEncode({
        "id": _currentUser!.id,
        "username": _currentUser!.username,
        "email": _currentUser!.email,
        "scan_count": _currentUser!.scanCount,
        "favorite_count": _currentUser!.favoriteCount,
      }));
    }
  }
}
