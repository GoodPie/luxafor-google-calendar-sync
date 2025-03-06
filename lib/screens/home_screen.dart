import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luxafor_calendar_sync/services/auth_service.dart';
import 'package:luxafor_calendar_sync/services/calendar_service.dart';
import 'package:luxafor_calendar_sync/services/luxafor_service.dart';
import 'package:luxafor_calendar_sync/services/storage_service.dart';
import 'package:luxafor_calendar_sync/widgets/status_card.dart';
import 'package:luxafor_calendar_sync/widgets/settings_card.dart';
import 'package:luxafor_calendar_sync/widgets/sync_control_card.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storage;
  final AuthService authService;
  final SharedPreferences prefs;

  const HomeScreen({
    Key? key,
    required this.storage,
    required this.authService,
    required this.prefs,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CalendarService _calendarService;
  late LuxaforService _luxaforService;
  bool _isAuthenticated = false;
  bool _isSyncRunning = false;
  bool _isInMeeting = false;
  String? _luxaforUserId;
  DateTime? _lastChecked;
  Timer? _syncTimer;
  int _syncInterval = 60; // Default: check every 60 seconds
  bool _statusOverride = false;
  String? _meetingTitle;
  bool _manualBusy = false;
  DateTime? _manualBusyUntil;
  Timer? _manualBusyTimer;

  @override
  void initState() {
    super.initState();
    _luxaforService = LuxaforService();
    _calendarService = CalendarService(widget.authService);

    // Load saved user ID and sync state
    _loadSavedSettings();

    // Check auth state
    _checkAuthState();

    // Load override status
    _statusOverride = widget.prefs.getBool('status_override') ?? false;
  }

  Future<void> _loadSavedSettings() async {
    setState(() {
      _luxaforUserId = widget.prefs.getString('luxafor_user_id');
      _syncInterval = widget.prefs.getInt('sync_interval') ?? 60;
      _isSyncRunning = widget.prefs.getBool('is_sync_running') ?? false;
    });

    // Start sync if it was running before
    if (_isSyncRunning) {
      _startSync();
    }
  }

  Future<void> _checkAuthState() async {
    try {
      final success = await widget.authService.authenticate();
      setState(() {
        _isAuthenticated = success;
      });
    } catch (e) {
      _handleAuthError(e.toString());
    }
  }

  Future<void> _authenticate() async {
    try {
      final success = await widget.authService.authenticate();
      setState(() {
        _isAuthenticated = success;
      });
    } catch (e) {
      _showError('Authentication Error', e.toString());
    }
  }

  Future<void> _signOut() async {
    try {
      await widget.authService.signOut();
      setState(() {
        _isAuthenticated = false;
        _isSyncRunning = false;
      });
      _stopSync();
    } catch (e) {
      _showError('Sign Out Error', e.toString());
    }
  }

  Future<void> _setLuxaforUserId(String userId) async {
    await widget.prefs.setString('luxafor_user_id', userId);
    setState(() {
      _luxaforUserId = userId;
    });
  }

  Future<void> _setSyncInterval(int seconds) async {
    await widget.prefs.setInt('sync_interval', seconds);
    setState(() {
      _syncInterval = seconds;
    });

    // Restart sync if it's running
    if (_isSyncRunning) {
      _stopSync();
      _startSync();
    }
  }

  void _startSync() {
    // Stop any existing timer
    _stopSync();

    // Don't start if not authenticated or no luxafor ID
    if (!_isAuthenticated ||
        _luxaforUserId == null ||
        _luxaforUserId!.isEmpty) {
      return;
    }

    // Save sync state
    widget.prefs.setBool('is_sync_running', true);

    // Create a new timer
    _syncTimer = Timer.periodic(Duration(seconds: _syncInterval), (_) {
      _checkCalendarAndUpdateLuxafor();
      print("Syncing...");
    });

    setState(() {
      _isSyncRunning = true;
    });

    // Run immediately
    _checkCalendarAndUpdateLuxafor();
  }

  void _stopSync() {
    _syncTimer?.cancel();
    _syncTimer = null;

    widget.prefs.setBool('is_sync_running', false);

    setState(() {
      _isSyncRunning = false;
    });
  }

  Future<void> _checkCalendarAndUpdateLuxafor() async {
    if (!_isAuthenticated ||
        _luxaforUserId == null ||
        _luxaforUserId!.isEmpty) {
      return;
    }

    try {
      // Check if there's a current event
      final status = await _calendarService.getCurrentMeetingStatus();
      final bool hasEvent = status['isInMeeting'] as bool;
      final String? eventTitle = status['meetingTitle'] as String?;

      // Determine status - prioritize manual busy over calendar
      // If manual busy is active, always show as busy
      // If status override is active, always show as available
      // Otherwise use calendar status
      bool effectiveStatus;
      if (_manualBusy) {
        effectiveStatus = true; // Manual busy takes highest priority
      } else if (_statusOverride) {
        effectiveStatus = false; // Override to available is second priority
      } else {
        effectiveStatus = hasEvent; // Calendar status is third priority
      }

      // Update the flag color based on effective status
      if (effectiveStatus) {
        await _luxaforService.setColor(_luxaforUserId!, 'red');
      } else {
        await _luxaforService.setColor(_luxaforUserId!, 'green');
      }

      // Update UI
      setState(() {
        _isInMeeting = hasEvent;
        _meetingTitle = eventTitle;
        _lastChecked = DateTime.now();
      });
    } catch (e) {
      print('Error syncing: $e');
    }
  }

  void _toggleStatusOverride() {
    setState(() {
      _statusOverride = !_statusOverride;
    });

    // Save the override status
    widget.prefs.setBool('status_override', _statusOverride);

    // Update the status immediately
    _checkCalendarAndUpdateLuxafor();
  }

  void _showError(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  // Add this method to set manual busy status
  void _setManualBusyStatus(int minutes) {
    // Clear any existing manual busy timer
    _manualBusyTimer?.cancel();

    if (minutes <= 0) {
      // If minutes is 0 or negative, clear manual busy status
      setState(() {
        _manualBusy = false;
        _manualBusyUntil = null;
      });

      // Update the light if sync is running
      if (_isSyncRunning) {
        _checkCalendarAndUpdateLuxafor();
      }
      return;
    }

    // Set manual busy status
    final endTime = DateTime.now().add(Duration(minutes: minutes));

    setState(() {
      _manualBusy = true;
      _manualBusyUntil = endTime;
    });

    // Set light to busy immediately if sync is running
    if (_isSyncRunning) {
      _luxaforService.setColor(_luxaforUserId!, 'red');
    }

    // Schedule timer to clear manual busy status
    _manualBusyTimer = Timer(Duration(minutes: minutes), () {
      setState(() {
        _manualBusy = false;
        _manualBusyUntil = null;
      });

      // Update the light if sync is running
      if (_isSyncRunning) {
        _checkCalendarAndUpdateLuxafor();
      }
    });
  }

  void _handleAuthError(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Authentication Error'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message),
                SizedBox(height: 16),
                Text(
                  'Please check that your credentials.json file is properly configured in the assets folder.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Luxafor Calendar Sync'),
        actions: [
          if (_isAuthenticated)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _signOut,
              tooltip: 'Sign Out',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status card showing current state
            // In home_screen.dart's build method, update the StatusCard call
            // In the build method, update the StatusCard
            StatusCard(
              isInMeeting: _isInMeeting,
              meetingTitle: _meetingTitle,
              lastChecked: _lastChecked,
              statusOverride: _statusOverride,
              onOverrideToggle: _toggleStatusOverride,
              manualBusy: _manualBusy,
              manualBusyUntil: _manualBusyUntil,
              onSetManualBusy: _setManualBusyStatus,
            ),

            SizedBox(height: 16),

            // Settings card for Luxafor and Google auth
            SettingsCard(
              isAuthenticated: _isAuthenticated,
              luxaforUserId: _luxaforUserId,
              onAuthenticate: _authenticate,
              onSetLuxaforUserId: _setLuxaforUserId,
            ),

            SizedBox(height: 16),

            // Sync control card
            SyncControlCard(
              isAuthenticated: _isAuthenticated,
              hasLuxaforId:
                  _luxaforUserId != null && _luxaforUserId!.isNotEmpty,
              isSyncRunning: _isSyncRunning,
              syncInterval: _syncInterval,
              onStartSync: _startSync,
              onStopSync: _stopSync,
              onChangeSyncInterval: _setSyncInterval,
            ),
          ],
        ),
      ),
    );
  }
}
