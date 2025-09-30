import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/notification_service.dart';
import 'viewmodels/reminder_viewmodel.dart';
import 'providers/theme_provider.dart';
import 'views/reminder_list_view.dart';

void main() async {
  // Needed if you intend to initialize in the main function
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the notification service early
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(const NoticaApp());
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
