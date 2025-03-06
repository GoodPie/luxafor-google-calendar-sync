import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luxafor_calendar_sync/screens/home_screen.dart';
import 'package:luxafor_calendar_sync/services/auth_service.dart';
import 'package:luxafor_calendar_sync/services/storage_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final storage = StorageService();
  final prefs = await SharedPreferences.getInstance();
  final authService = AuthService(storage);
  
  runApp(MyApp(
    storage: storage,
    authService: authService,
    prefs: prefs,
  ));
}

class MyApp extends StatelessWidget {
  final StorageService storage;
  final AuthService authService;
  final SharedPreferences prefs;

  const MyApp({
    Key? key,
    required this.storage,
    required this.authService,
    required this.prefs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luxafor Calendar Sync',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: HomeScreen(
        storage: storage, 
        authService: authService,
        prefs: prefs,
      ),
    );
  }
}