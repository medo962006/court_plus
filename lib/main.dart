import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'routes.dart';
import 'core/logger.dart';
import 'core/config.dart';
import 'core/di.dart';
import 'services/supabase_service.dart';
import 'services/deep_link_service.dart';
import 'services/payment_service.dart';
import 'presentation/providers/service_providers.dart';
import 'l10n/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  AppLogger.init();
  await AppConfig.init();
  await setupDependencyInjection();
  await SupabaseService().init();
  await PaymentService().init();

  final prefs = await SharedPreferences.getInstance();
  final savedLocale = prefs.getString('language') ?? 'en';

  runApp(ProviderScope(child: CourtPlusApp(initialLocale: savedLocale)));
}

class CourtPlusApp extends ConsumerStatefulWidget {
  final String initialLocale;
  const CourtPlusApp({super.key, this.initialLocale = 'en'});

  @override
  ConsumerState<CourtPlusApp> createState() => CourtPlusAppState();
}

class CourtPlusAppState extends ConsumerState<CourtPlusApp> {
  late String _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deepLinkServiceProvider).init();
    });
  }

  void setLocale(String locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'court+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      navigatorKey: DeepLinkService.navigatorKey,
      initialRoute: Routes.splash,
      routes: Routes.map,
      locale: Locale(_locale),
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (_locale == 'ar') return const Locale('ar');
        return const Locale('en');
      },
      builder: (context, child) {
        return AppStringsInherited(
          locale: _locale,
          child: child!,
        );
      },
    );
  }
}