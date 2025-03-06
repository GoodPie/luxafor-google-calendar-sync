import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:luxafor_calendar_sync/services/storage_service.dart';

class AuthService {
  final StorageService _storage;
  late ClientId _clientId;
  bool _isInitialized = false;

  // Scopes required for Google Calendar
  final List<String> _scopes = [
    'https://www.googleapis.com/auth/calendar.readonly',
  ];

  AuthService(this._storage);

  // Initialize credentials from file
  Future<void> _initCredentials() async {
    if (_isInitialized) return;
    
    try {
      // Load the credentials file from assets
      final jsonString = await rootBundle.loadString('assets/google_calendar_credentials.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // Extract client ID and secret
      // The structure depends on whether it's a web or desktop credentials file
      String clientId, clientSecret;
      
      if (jsonData.containsKey('installed')) {
        // Desktop app credentials format
        clientId = jsonData['installed']['client_id'];
        clientSecret = jsonData['installed']['client_secret'];
      } else if (jsonData.containsKey('web')) {
        // Web app credentials format
        clientId = jsonData['web']['client_id'];
        clientSecret = jsonData['web']['client_secret'];
      } else {
        throw Exception('Unknown credentials format');
      }
      
      // Create ClientId object
      _clientId = ClientId(clientId, clientSecret);
      _isInitialized = true;
    } catch (e) {
      print('Error initializing credentials: $e');
      rethrow;
    }
  }

  // Check if the user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final token = await _storage.getToken();
      if (token == null) return false;
      
      // Check if token is expired
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(
        token['expiry'] as int,
      );
      
      return expiryDate.isAfter(DateTime.now());
    } catch (e) {
      print('Error checking authentication: $e');
      return false;
    }
  }

  // Get access token for API calls
  Future<String?> getAccessToken() async {
    try {
      if (!await isAuthenticated()) {
        return null;
      }
      
      final token = await _storage.getToken();
      return token?['access_token'] as String?;
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
  }

  // Authenticate with Google
  Future<bool> authenticate() async {
    try {
      // Initialize credentials if not already done
      await _initCredentials();
      
      // Create client credentials
      final client = await clientViaUserConsent(
        _clientId,
        _scopes,
        _openUrl,
      );
      
      // Store token
      final accessToken = client.credentials.accessToken.data;
      final refreshToken = client.credentials.refreshToken;
      final expiry = client.credentials.accessToken.expiry.millisecondsSinceEpoch;
      
      await _storage.saveToken({
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expiry': expiry,
      });
      
      // Close the client
      client.close();
      
      return true;
    } catch (e) {
      print('Authentication error: $e');
      return false;
    }
  }

  // Sign out by removing token
  Future<void> signOut() async {
    await _storage.deleteToken();
  }

  // Helper to open URL for OAuth consent
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Could not launch $url');
    }
  }
}