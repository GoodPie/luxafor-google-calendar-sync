import 'dart:convert';
import 'package:http/http.dart' as http;

class LuxaforService {
  // API Endpoints based on the Luxafor documentation
  static const String _baseUrl = 'https://api.luxafor.com/webhook/v1/actions';
  static const String _solidColorEndpoint = '$_baseUrl/solid_color';
  static const String _blinkEndpoint = '$_baseUrl/blink';
  static const String _patternEndpoint = '$_baseUrl/pattern';

  // Set solid color (red when in meeting, green when free)
  Future<bool> setColor(String userId, String color) async {
    try {
      // Ensure color is one of the accepted values
      if (!_isValidBasicColor(color)) {
        throw Exception('Invalid color: $color. Must be one of: red, green, yellow, blue, white, cyan, magenta');
      }
      
      // Prepare request payload
      final Map<String, dynamic> payload = {
        'userId': userId,
        'actionFields': {
          'color': color,
        },
      };
      
      // Make API request
      final response = await http.post(
        Uri.parse(_solidColorEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error setting Luxafor color: $e');
      rethrow;
    }
  }

  // Set custom color using hex code
  Future<bool> setCustomColor(String userId, String hexColor) async {
    try {
      // Validate hex color format
      if (!_isValidHexColor(hexColor)) {
        throw Exception('Invalid hex color: $hexColor. Must be 6-character hex code without #');
      }
      
      // Prepare request payload
      final Map<String, dynamic> payload = {
        'userId': userId,
        'actionFields': {
          'color': 'custom',
          'custom_color': hexColor,
        },
      };    
      
      // Make API request
      final response = await http.post(
        Uri.parse(_solidColorEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error setting Luxafor custom color: $e');
      rethrow;
    }
  }

  // Blink the Luxafor flag
  Future<bool> blink(String userId, String color) async {
    try {
      // Ensure color is one of the accepted values
      if (!_isValidBasicColor(color)) {
        throw Exception('Invalid color: $color. Must be one of: red, green, yellow, blue, white, cyan, magenta');
      }
      
      // Prepare request payload
      final Map<String, dynamic> payload = {
        'userId': userId,
        'actionFields': {
          'color': color,
        },
      };
      
      // Make API request
      final response = await http.post(
        Uri.parse(_blinkEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error blinking Luxafor flag: $e');
      rethrow;
    }
  }

  // Show a pattern on the Luxafor flag
  Future<bool> showPattern(String userId, String pattern) async {
    try {
      // Ensure pattern is one of the accepted values
      if (!_isValidPattern(pattern)) {
        throw Exception('Invalid pattern: $pattern');
      }
      
      // Prepare request payload
      final Map<String, dynamic> payload = {
        'userId': userId,
        'actionFields': {
          'pattern': pattern,
        },
      };
      
      // Make API request
      final response = await http.post(
        Uri.parse(_patternEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error showing Luxafor pattern: $e');
      rethrow;
    }
  }

  // Turn off the Luxafor flag
  Future<bool> turnOff(String userId) async {
    // According to the documentation, sending 000000 as a custom color turns off the device
    return setCustomColor(userId, '000000');
  }

  // Helper method to check if a color is valid
  bool _isValidBasicColor(String color) {
    final validColors = ['red', 'green', 'yellow', 'blue', 'white', 'cyan', 'magenta'];
    return validColors.contains(color.toLowerCase());
  }

  // Helper method to check if a hex color is valid
  bool _isValidHexColor(String color) {
    // Must be 6 characters and contain only hex digits
    final hexPattern = RegExp(r'^[0-9A-Fa-f]{6}$');
    return hexPattern.hasMatch(color);
  }

  // Helper method to check if a pattern is valid
  bool _isValidPattern(String pattern) {
    final validPatterns = [
      'police', 'traffic lights', 'random 1', 'random 2',
      'random 3', 'random 4', 'random 5', 'rainbow',
      'sea', 'white wave', 'synthetic'
    ];
    return validPatterns.contains(pattern.toLowerCase());
  }
}