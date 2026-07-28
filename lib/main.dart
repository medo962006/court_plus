import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'routes.dart';
import 'core/logger.dart';
import 'core/config.dart';
import 'core/di.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize infrastructure
  AppLogger.init();
  await AppConfig.init();
  await setupDependencyInjection();
  await SupabaseService().init();

  runApp(const CourtPlusApp());
}

class CourtPlusApp extends StatelessWidget {
  const CourtPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'court+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      initialRoute: Routes.splash,
      routes: Routes.map,
    );
  }
}