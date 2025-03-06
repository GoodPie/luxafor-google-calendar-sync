import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:luxafor_calendar_sync/services/auth_service.dart';

class CalendarService {
  final AuthService _authService;
  
  CalendarService(this._authService);

  // Check if there are any current events in progress
  Future<bool> hasCurrentEvents() async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) {
        throw Exception('Not authenticated');
      }
      
      // Calculate current time in ISO format
      final now = DateTime.now().toUtc();
      final timeMin = now.toIso8601String();
      final timeMax = now.add(Duration(minutes: 1)).toIso8601String();
      
      // Build URL with query parameters
      final uri = Uri.parse(
        'https://www.googleapis.com/calendar/v3/calendars/primary/events'
        '?timeMin=${Uri.encodeComponent(timeMin)}'
        '&timeMax=${Uri.encodeComponent(timeMax)}'
        '&singleEvents=true'
        '&orderBy=startTime'
      );
      
      // Make request
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode != 200) {
        throw Exception('Calendar API error: ${response.statusCode}');
      }
      
      // Parse response
      final data = jsonDecode(response.body);
      final events = data['items'] as List<dynamic>;

      // Return true if there are any events
      return events.isNotEmpty;
    } catch (e) {
      print('Error checking calendar events: $e');
      rethrow;
    }
  }
}