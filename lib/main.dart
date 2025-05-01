
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'screens/absence_screen.dart';
import 'screens/dev_seed_screen.dart';
import 'screens/assign_substitute_screen.dart';
import 'screens/substitution_from_absence_screen.dart';
import 'screens/substitution_from_absence_debug_screen.dart';
import 'screens/mark_absence_screen.dart';
import 'screens/daily_absences_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xgiqfjvnrblsmzpselnr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhnaXFmanZucmJsc216cHNlbG5yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU1MjQyMTAsImV4cCI6MjA2MTEwMDIxMH0.zxC9VnEFatDaxlky2L0MRLevN3CBwPrQMZ4CBZn4RR4',
  );

  if (!kIsWeb) {
    await Permission.storage.request();
  }

  // Initialize notification settings
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const TeacherAttendanceApp());
}

class TeacherAttendanceApp extends StatelessWidget {
  const TeacherAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام غياب المعلمين',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        fontFamily: 'Cairo',
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      home: const DailyAbsencesScreen(),
    );
  }
}
