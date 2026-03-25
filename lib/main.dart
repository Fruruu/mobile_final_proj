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

  Route<dynamic> _buildRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case '/home':
        return _noTransitionRoute(const HomeScreen(), settings);
      case '/checkin':
        return _noTransitionRoute(const CheckinScreen(), settings);
      case '/journal':
        return _noTransitionRoute(const JournalScreen(), settings);
      case '/history':
        return _noTransitionRoute(const HistoryScreen(), settings);
      case '/report':
        return _noTransitionRoute(const ReportScreen(), settings);
      case '/insight':
        return MaterialPageRoute(
          builder: (_) => const InsightScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
    }
  }

  PageRouteBuilder _noTransitionRoute(Widget child, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

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
      onGenerateRoute: _buildRoute,
    );
  }
}
