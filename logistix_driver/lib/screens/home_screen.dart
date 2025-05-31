import 'package:flutter/material.dart';
import 'package:logistix_driver/models/notification_model.dart';
import 'package:logistix_driver/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<NotificationModel> _notifications = [];
  late final NotificationService _notificationService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeNotificationService();
  }

  Future<void> _initializeNotificationService() async {
    _notificationService = NotificationService();
    await _notificationService.initialize();
    debugPrint('HomeScreen: Notification service initialized');
    
    _notificationService.notificationStream.listen((notification) {
      debugPrint('HomeScreen: Received notification: ${notification.title} - ${notification.body}');
      setState(() {
        _notifications.insert(0, notification); // Add new notifications at the top
        debugPrint('HomeScreen: Updated notifications list. Count: ${_notifications.length}');
      });
    });
    
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _notificationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logistix Driver'),
      ),
      body: Column(
        children: [
          if (_notifications.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Notifications',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: ListTile(
                      title: Text(notification.title ?? 'No Title'),
                      subtitle: Text(notification.body ?? 'No Content'),
                      trailing: Text(
                        _formatTimestamp(notification.timestamp ?? DateTime.now()),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else
            const Expanded(
              child: Center(
                child: Text('No notifications yet'),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
} 