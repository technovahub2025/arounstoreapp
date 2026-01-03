import 'dart:convert';
import 'package:arunstore/model/model/rolechoose.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthManager with ChangeNotifier {
  static final AuthManager _instance = AuthManager._internal();
  
  factory AuthManager() => _instance;
  
  AuthManager._internal();
  
  User? _currentUser;
  String? _token;
  bool _initialized = false;
 
  bool get isInitialized => _initialized;
  User? get currentUser => _currentUser;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  String? get token => _token;

  bool get isLoggedIn {
    if (!_initialized) {
      return false;
    }
    return _currentUser != null && _token != null && _token!.isNotEmpty;
  }
  
  // Base URL for your API
  static const String baseUrl = "https://aroun-shopping-website-a2he.onrender.com/api/auth";
  
  // Login with API - UPDATED to handle your JSON response format
  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      );
      
     
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // EXTRACT TOKEN - Based on your JSON response format
        // Your response has both 'token' and 'user.token'
        _token = data['token'] ?? data['user']['token'];
        
        if (_token == null || _token!.isEmpty) {
          return {
            'success': false,
            'message': 'No authentication token received',
          };
        }
        
        // Create user from response
        final userData = data['user'];
        _currentUser = User(
          id: userData['id'] ?? userData['_id'] ?? '',
          name: userData['name'] ?? '',
          phone: userData['phone'] ?? '',
          role: userData['role'] ?? 'user',
          token: _token,
        );
        
       
        // Save to storage
        await _saveToStorage();
        
        // IMPORTANT: Notify listeners AFTER saving
        notifyListeners();
        
        return {
          'success': true,
          'message': data['message'] ?? 'Login successful',
          'user': _currentUser,
          'token': _token, // Explicitly include token in response
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed. Status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
  
  // Register new user - UPDATED
  Future<Map<String, dynamic>> register(String name, String phone, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'password': password,
          'role': role,
        }),
      );
      
     
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        // EXTRACT TOKEN
        _token = data['token'] ?? data['user']['token'];
        
        if (_token == null || _token!.isEmpty) {
          return {
            'success': false,
            'message': 'No authentication token received',
          };
        }
        
        // Create user from response
        final userData = data['user'];
        _currentUser = User(
          id: userData['id'] ?? userData['_id'] ?? '',
          name: userData['name'] ?? '',
          phone: userData['phone'] ?? '',
          role: userData['role'] ?? role,
          token: _token,
        );
        
        // Save to storage
        await _saveToStorage();
        notifyListeners();
        
        return {
          'success': true,
          'message': data['message'] ?? 'Registration successful',
          'user': _currentUser,
          'token': _token,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed. Status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      if (kDebugMode) {
       
      }
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
  
  // Fetch user profile with token
  Future<void> fetchUserProfile() async {
    if (_token == null || _token!.isEmpty) {
      
      return;
    }
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
      );
      
   
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['user'] ?? data;
        
        _currentUser = User(
          id: userData['id'] ?? userData['_id'] ?? '',
          name: userData['name'] ?? '',
          phone: userData['phone'] ?? '',
          role: userData['role'] ?? 'user',
          token: _token,
        );
        
        // Update storage with fresh data
        await _saveToStorage();
        notifyListeners();
        
        if (kDebugMode) {
        
        }
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        if (kDebugMode) {
         
        }
        await logout();
      }
    } catch (e) {
      if (kDebugMode) {
      
      }
    }
  }
  
  // Logout
  Future<void> logout() async {
    if (kDebugMode) {
    
    }
    
    _currentUser = null;
    _token = null;
    
    await _clearStorage();
    notifyListeners();
    
    if (kDebugMode) {
  
    }
  }
  
  // Initialize from storage
  Future<void> initialize() async {
    if (_initialized) {
     
      return;
    }
    
    try {
   
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      _token = prefs.getString('token');
      
   
      
      if (userJson != null && _token != null && _token!.isNotEmpty) {
        try {
          final userData = jsonDecode(userJson);
          _currentUser = User(
            id: userData['id'] ?? '',
            name: userData['name'] ?? '',
            phone: userData['phone'] ?? '',
            role: userData['role'] ?? 'user',
            token: _token,
          );
          
          if (kDebugMode) {
        
          }
        } catch (e) {
         
          await _clearStorage();
          _currentUser = null;
          _token = null;
        }
      } else {
        if (kDebugMode) {
       }
        _currentUser = null;
        _token = null;
      }
    } catch (e) {
      if (kDebugMode) {
      
      }
      _currentUser = null;
      _token = null;
    } finally {
      _initialized = true;
  
      notifyListeners();
    }
  }
  
  // Save to storage
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_currentUser != null) {
        final userJson = {
          'id': _currentUser!.id,
          'name': _currentUser!.name,
          'phone': _currentUser!.phone,
          'role': _currentUser!.role,
        };
        await prefs.setString('user', jsonEncode(userJson));
        
       
      }
      
      if (_token != null && _token!.isNotEmpty) {
        await prefs.setString('token', _token!);
     
      }
      
    } catch (e) {
     
    }
  }
  
  // Clear storage
  Future<void> _clearStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      await prefs.remove('token');
 
    } catch (e) {
  
    }
  }
  
 
  int min(int a, int b) => a < b ? a : b;
}