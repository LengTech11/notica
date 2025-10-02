import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'services/notification_service.dart';
import 'services/onboarding_service.dart';
import 'viewmodels/reminder_viewmodel.dart';
import 'providers/theme_provider.dart';
import 'views/reminder_list_view.dart';

void main() async {
  // Needed if you intend to initialize in the main function
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();

  // Initialize the notification service early
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize the onboarding service
  final onboardingService = OnboardingService();
  await onboardingService.initialize();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('km'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const NoticaApp(),
    ),
  );
}

class NoticaApp extends StatelessWidget {
  const NoticaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ReminderViewModel()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Notica',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
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
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final isOnboardingComplete = snapshot.data ?? false;

        // Use addPostFrameCallback to navigate after the build is complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isOnboardingComplete) {
            Navigator.of(context).pushReplacementNamed('/home');
          } else {
            Navigator.of(context).pushReplacementNamed('/onboarding');
          }
        });

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
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
    // Initialize the reminder view model and theme provider when the app starts
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
