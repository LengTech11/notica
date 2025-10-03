import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/notification_service.dart';
import '../services/firebase_messaging_service.dart';

/// Developer view for testing push notifications and Firebase Cloud Messaging
class PushNotificationTestView extends StatefulWidget {
  const PushNotificationTestView({super.key});

  @override
  State<PushNotificationTestView> createState() => _PushNotificationTestViewState();
}

class _PushNotificationTestViewState extends State<PushNotificationTestView> {
  String? _fcmToken;
  bool _isLoading = false;
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadFCMToken();
  }

  Future<void> _loadFCMToken() async {
    setState(() => _isLoading = true);
    try {
      final token = await FirebaseMessagingService().getToken();
      setState(() {
        _fcmToken = token;
        _addLog('✅ FCM Token loaded');
      });
    } catch (e) {
      setState(() {
        _addLog('❌ Failed to load FCM token: $e');
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.insert(0, '${DateTime.now().toString().substring(11, 19)} - $message');
      if (_logs.length > 20) {
        _logs.removeLast();
      }
    });
  }

  Future<void> _testLocalNotification() async {
    _addLog('🔔 Sending local notification...');
    try {
      await NotificationService().showImmediateNotification(
        'Test Local Notification',
        'This is a test notification from the app',
      );
      _addLog('✅ Local notification sent');
    } catch (e) {
      _addLog('❌ Error: $e');
    }
  }

  Future<void> _subscribeToTopic(String topic) async {
    _addLog('🔥 Subscribing to topic: $topic...');
    try {
      await FirebaseMessagingService().subscribeToTopic(topic);
      _addLog('✅ Subscribed to $topic');
    } catch (e) {
      _addLog('❌ Error subscribing: $e');
    }
  }

  Future<void> _unsubscribeFromTopic(String topic) async {
    _addLog('🔥 Unsubscribing from topic: $topic...');
    try {
      await FirebaseMessagingService().unsubscribeFromTopic(topic);
      _addLog('✅ Unsubscribed from $topic');
    } catch (e) {
      _addLog('❌ Error unsubscribing: $e');
    }
  }

  void _copyTokenToClipboard() {
    if (_fcmToken != null) {
      Clipboard.setData(ClipboardData(text: _fcmToken!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('FCM token copied to clipboard')),
      );
      _addLog('📋 Token copied to clipboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notification Testing'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Platform Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Platform.isIOS ? Icons.apple : Icons.android,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Platform: ${Platform.isIOS ? 'iOS' : 'Android'}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (Platform.isIOS) ...[
                    const Text(
                      '📱 iOS Push Notifications',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('✅ Foreground: Local notifications'),
                    const Text('✅ Background: Local notifications'),
                    const Text('❌ Killed: Requires APNs key'),
                  ] else ...[
                    const Text(
                      '🤖 Android Push Notifications',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('✅ Foreground: FCM native'),
                    const Text('✅ Background: FCM native'),
                    const Text('✅ Killed: FCM native'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // FCM Token Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'FCM Token',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (_isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_fcmToken != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        _fcmToken!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _copyTokenToClipboard,
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Token'),
                    ),
                  ] else ...[
                    const Text('No token available. Firebase may not be configured.'),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _loadFCMToken,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Test Actions Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test Actions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _testLocalNotification,
                      icon: const Icon(Icons.notifications),
                      label: const Text('Test Local Notification'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _subscribeToTopic('test_topic'),
                      icon: const Icon(Icons.add_alert),
                      label: const Text('Subscribe to test_topic'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _unsubscribeFromTopic('test_topic'),
                      icon: const Icon(Icons.notifications_off),
                      label: const Text('Unsubscribe from test_topic'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Instructions Card
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'How to Test',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1. Test local notifications work first\n'
                    '2. Copy your FCM token above\n'
                    '3. Go to Firebase Console → Cloud Messaging\n'
                    '4. Send test message to your token OR\n'
                    '5. Subscribe to test_topic and send to topic\n'
                    '6. Test in foreground, background, and killed states',
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      // Open documentation
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('See TESTING_PUSH_NOTIFICATIONS.md for details'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.book),
                    label: const Text('View Documentation'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Logs Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Activity Log',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _logs.clear()),
                        tooltip: 'Clear logs',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _logs.isEmpty
                        ? const Center(
                            child: Text(
                              'No activity yet',
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _logs.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  _logs[index],
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
