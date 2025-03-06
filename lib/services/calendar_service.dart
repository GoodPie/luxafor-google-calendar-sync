import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:luxafor_calendar_sync/services/auth_service.dart';

class CalendarService {
  final AuthService _authService;

  CalendarService(this._authService);

  Future<Map<String, dynamic>> getCurrentMeetingStatus() async {
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
        '&orderBy=startTime',
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

      if (events.isEmpty) {
        return {'isInMeeting': false, 'meetingTitle': null};
      }

      // Find the first event where you're marked as busy
      // Google Calendar uses 'transparency' field where:
      // - 'opaque' (default) means you're busy
      // - 'transparent' means you're free/available
      for (final event in events) {
        // Check if the event is marked as "busy" (either no transparency field or transparency = 'opaque')
        final String? transparency = event['transparency'] as String?;
        final bool isBusy = transparency == null || transparency == 'opaque';

        if (isBusy) {
          return {
            'isInMeeting': true,
            'meetingTitle': event['summary'] as String?,
          };
        }
      }

      // No busy events found
      return {'isInMeeting': false, 'meetingTitle': null};
    } catch (e) {
      print('Error checking calendar events: $e');
      rethrow;
    }
  }

  // Keep the existing method for backward compatibility
  Future<bool> hasCurrentEvents() async {
    final status = await getCurrentMeetingStatus();
    return status['isInMeeting'] as bool;
  }
}
