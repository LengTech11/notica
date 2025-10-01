import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'services/notification_service.dart';
import 'services/onboarding_service.dart';
import 'viewmodels/reminder_viewmodel.dart';

import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';

import 'views/reminder_list_view.dart';
import 'views/onboarding_view.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final notificationService = NotificationService();
  await notificationService.initialize();

  final onboardingService = OnboardingService();
  await onboardingService.initialize();

  runApp(const NoticaApp());
}

class NoticaApp extends StatelessWidget {
  const NoticaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReminderViewModel()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, child) {
          return MaterialApp(
            title: 'Notica',
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('km'), // Khmer
            ],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(centerTitle: true),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(centerTitle: true),
            ),
            themeMode: themeProvider.themeMode,
            home: const NoticaHome(),
            routes: {
              '/home': (_) => const NoticaHome(),
              '/onboarding': (_) => const OnboardingView(),
            },
          );
        },
      ),
    );
  }
}

/// Widget that determines whether to show onboarding or home screen
class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: OnboardingService().isOnboardingComplete(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isOnboardingComplete = snapshot.data ?? false;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isOnboardingComplete) {
            Navigator.of(context).pushReplacementNamed('/home');
          } else {
            Navigator.of(context).pushReplacementNamed('/onboarding');
          }
        });

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class NoticaHome extends StatefulWidget {
  const NoticaHome({super.key});

  @override
  State<NoticaHome> createState() => _NoticaHomeState();
}

class _NoticaHomeState extends State<NoticaHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReminderViewModel>(context, listen: false).initialize();
      Provider.of<ThemeProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const ReminderListView();
  }
}
