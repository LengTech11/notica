import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/notification_service.dart';
import 'viewmodels/habit_viewmodel.dart';
import 'views/habit_list_view.dart';

void main() async {
  // Needed if you intend to initialize in the main function
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the notification service early
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(const HabitTrackerApp());
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HabitViewModel(),
      child: MaterialApp(
        title: 'Habit Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true),
        ),
        themeMode: ThemeMode.system,
        home: const HabitTrackerHome(),
      ),
    );
  }
}

class HabitTrackerHome extends StatefulWidget {
  const HabitTrackerHome({super.key});

  @override
  State<HabitTrackerHome> createState() => _HabitTrackerHomeState();
}

class _HabitTrackerHomeState extends State<HabitTrackerHome> {
  @override
  void initState() {
    super.initState();
    // Initialize the habit view model when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HabitViewModel>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const HabitListView();
  }
}
