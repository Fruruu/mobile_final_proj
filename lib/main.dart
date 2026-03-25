import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'view_models/auth_view_model.dart';
import 'view_models/checkin_view_model.dart';
import 'view_models/journal_view_model.dart';
import 'view_models/insight_view_model.dart';
import 'view_models/history_view_model.dart';
import 'view_models/home_view_model.dart';
import 'view_models/report_view_model.dart';
import 'views/auth/login_screen.dart';
import 'views/home_screen.dart';
import 'views/checkin/checkin_screen.dart';
import 'views/journal/journal_screen.dart';
import 'views/insight/insight_screen.dart';
import 'views/history/history_screen.dart';
import 'views/report/report_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => CheckinViewModel()),
        ChangeNotifierProvider(create: (_) => JournalViewModel()),
        ChangeNotifierProvider(create: (_) => InsightViewModel()),
        ChangeNotifierProvider(create: (_) => HistoryViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => ReportViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Path',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login':    (_) => const LoginScreen(),
        '/home':     (_) => const HomeScreen(),
        '/checkin':  (_) => const CheckinScreen(),
        '/journal':  (_) => const JournalScreen(),
        '/insight':  (_) => const InsightScreen(),
        '/history':  (_) => const HistoryScreen(),
        '/report':   (_) => const ReportScreen(),
      },
    );
  }
}