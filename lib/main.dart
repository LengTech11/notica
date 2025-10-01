import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/notification_service.dart';
import 'services/onboarding_service.dart';
import 'viewmodels/reminder_viewmodel.dart';
import 'views/reminder_list_view.dart';
import 'views/onboarding_view.dart';

void main() async {
  // Needed if you intend to initialize in the main function
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the notification service early
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize the onboarding service
  final onboardingService = OnboardingService();
  await onboardingService.initialize();

  runApp(const NoticaApp());
}

class NoticaApp extends StatelessWidget {
  const NoticaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReminderViewModel(),
      child: MaterialApp(
        title: 'Notica',
        debugShowCheckedModeBanner: false,
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
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => const AppInitializer(),
          '/home': (context) => const NoticaHome(),
          '/onboarding': (context) => const OnboardingView(),
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
    // Initialize the reminder view model when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReminderViewModel>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const ReminderListView();
  }
}
