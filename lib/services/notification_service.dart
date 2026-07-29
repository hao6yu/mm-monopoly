import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../config/board_configs/classic_board.dart';
import '../config/board_configs/japan_board.dart';
import '../config/board_configs/uk_board.dart';
import '../config/board_configs/france_board.dart';
import '../config/board_configs/china_board.dart';
import '../config/board_configs/mexico_board.dart';
import '../models/tile.dart';

/// Service for scheduling fun fact notifications to engage users
class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  static final Random _random = Random();

  // Notification channel for Android
  static const String _channelId = 'fun_facts_channel';
  static const String _channelName = 'Fun Facts';
  static const String _channelDescription =
      'Interesting facts about places around the world';

  // Preference keys
  static const String _lastScheduledKey = 'notifications_last_scheduled';
  static const String _notificationIdsKey = 'scheduled_notification_ids';

  /// All available boards with their names
  static final List<_BoardInfo> _boards = [
    _BoardInfo('Classic', 'Atlantic City', ClassicBoard.generateTiles),
    _BoardInfo('Japan', 'Tokyo', JapanBoard.generateTiles),
    _BoardInfo('UK', 'London', UKBoard.generateTiles),
    _BoardInfo('France', 'Paris', FranceBoard.generateTiles),
    _BoardInfo('China', 'Beijing', ChinaBoard.generateTiles),
    _BoardInfo('Mexico', 'Mexico City', MexicoBoard.generateTiles),
  ];

  /// Initialize the notification service
  Future<void> init() async {
    if (_initialized) return;

    try {
      // Initialize timezone
      tz_data.initializeTimeZones();

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // Request permission explicitly after initialization so scheduling can be
      // skipped when iOS denies or cannot provide notification authorization.
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        // Show notifications even when app is in foreground
        notificationCategories: [
          DarwinNotificationCategory(
            'funFacts',
            actions: <DarwinNotificationAction>[],
            options: <DarwinNotificationCategoryOption>{
              DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
            },
          ),
        ],
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      _initialized = true;

      final permissionGranted = await requestPermissions();
      if (!permissionGranted) {
        debugPrint(
          'Notifications are disabled; weekly scheduling was skipped.',
        );
        return;
      }

      // Schedule notifications if needed.
      await _scheduleWeeklyNotificationsIfNeeded();
    } on PlatformException catch (error, stackTrace) {
      // Notifications are optional. A denied permission or simulator
      // notification-service failure must never prevent the game from opening.
      debugPrint('Notification initialization skipped: $error');
      debugPrintStack(stackTrace: stackTrace);
    } catch (error, stackTrace) {
      debugPrint('Notification initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    // For now, just opening the app is enough
    // In the future, could deep link to specific board
  }

  /// Request notification permissions (iOS)
  Future<bool> requestPermissions() async {
    final iOS =
        _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

    if (iOS != null) {
      final granted = await iOS.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    final android =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    return true;
  }

  /// Schedule weekly notifications if not already scheduled this week
  Future<void> _scheduleWeeklyNotificationsIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final lastScheduled = prefs.getInt(_lastScheduledKey) ?? 0;
    final now = DateTime.now();
    final lastScheduledDate = DateTime.fromMillisecondsSinceEpoch(
      lastScheduled,
    );

    // Check if we need to reschedule (different week)
    final needsReschedule = _isDifferentWeek(lastScheduledDate, now);

    if (needsReschedule) {
      await _cancelAllScheduledNotifications();
      await _scheduleWeeklyNotifications();
      await prefs.setInt(_lastScheduledKey, now.millisecondsSinceEpoch);
    }
  }

  /// Check if two dates are in different weeks
  bool _isDifferentWeek(DateTime date1, DateTime date2) {
    // Get the Monday of each week
    final monday1 = date1.subtract(Duration(days: date1.weekday - 1));
    final monday2 = date2.subtract(Duration(days: date2.weekday - 1));

    return monday1.year != monday2.year ||
        monday1.month != monday2.month ||
        monday1.day != monday2.day;
  }

  /// Schedule 2-3 notifications for the current week
  Future<void> _scheduleWeeklyNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final scheduledIds = <int>[];

    // Decide how many notifications this week (2 or 3)
    final notificationCount = _random.nextBool() ? 2 : 3;

    // Pick random days this week (excluding today if it's late)
    final availableDays = _getAvailableDaysThisWeek(now);

    if (availableDays.isEmpty) return;

    // Shuffle and pick days
    availableDays.shuffle(_random);
    final selectedDays = availableDays.take(notificationCount).toList();

    for (int i = 0; i < selectedDays.length; i++) {
      final day = selectedDays[i];
      final funFact = _getRandomFunFact();

      if (funFact != null) {
        // Schedule for evening (random time between 6-8 PM)
        final hour = 18 + _random.nextInt(2); // 18 or 19 (6 PM or 7 PM)
        final minute = _random.nextInt(60);

        final scheduledDate = DateTime(
          day.year,
          day.month,
          day.day,
          hour,
          minute,
        );

        // Only schedule if in the future
        if (scheduledDate.isAfter(now)) {
          final notificationId = _generateNotificationId(i, day);
          scheduledIds.add(notificationId);

          await _scheduleNotification(
            id: notificationId,
            title: funFact.title,
            body: funFact.body,
            scheduledDate: scheduledDate,
          );
        }
      }
    }

    // Save scheduled notification IDs for later cancellation
    await prefs.setStringList(
      _notificationIdsKey,
      scheduledIds.map((id) => id.toString()).toList(),
    );
  }

  /// Get available days this week for notifications
  List<DateTime> _getAvailableDaysThisWeek(DateTime now) {
    final days = <DateTime>[];
    final currentWeekday = now.weekday;

    // Add remaining days this week
    for (int i = currentWeekday; i <= 7; i++) {
      final day = now.add(Duration(days: i - currentWeekday));

      // Skip today if it's already past 8 PM
      if (i == currentWeekday && now.hour >= 20) continue;

      days.add(DateTime(day.year, day.month, day.day));
    }

    return days;
  }

  /// Generate a unique notification ID
  int _generateNotificationId(int index, DateTime day) {
    return day.year * 10000 + day.month * 100 + day.day + index;
  }

  /// Get a random fun fact from any board
  _FunFactNotification? _getRandomFunFact() {
    // Pick a random board
    final boardInfo = _boards[_random.nextInt(_boards.length)];
    final tiles = boardInfo.generateTiles();

    // Get tiles with fun facts (properties, railroads, utilities)
    final tilesWithFacts = tiles.where((tile) => tile.funFact != null).toList();

    if (tilesWithFacts.isEmpty) return null;

    // Pick a random tile
    final tile = tilesWithFacts[_random.nextInt(tilesWithFacts.length)];

    // Create notification content
    final emoji = _getEmojiForTile(tile);
    final title = '$emoji Did You Know?';
    final body = '${tile.funFact!}\n\n— ${tile.name}, ${boardInfo.cityName}';

    return _FunFactNotification(title: title, body: body);
  }

  /// Get emoji for tile type
  String _getEmojiForTile(TileData tile) {
    if (tile is PropertyTileData) return '🏠';
    if (tile is RailroadTileData) return '🚂';
    if (tile is UtilityTileData) {
      return (tile).isElectric ? '⚡' : '💧';
    }
    return '🎲';
  }

  /// Schedule a single notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      styleInformation: BigTextStyleInformation(body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  /// Cancel all scheduled notifications
  Future<void> _cancelAllScheduledNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_notificationIdsKey) ?? [];

    for (final idStr in ids) {
      final id = int.tryParse(idStr);
      if (id != null) {
        await _notifications.cancel(id);
      }
    }

    await prefs.setStringList(_notificationIdsKey, []);
  }

  /// Force reschedule notifications (for testing or after app update)
  Future<void> rescheduleNotifications() async {
    await _cancelAllScheduledNotifications();
    await _scheduleWeeklyNotifications();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _lastScheduledKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Check if notifications are likely enabled
  /// Note: Can't directly check system settings, but can check pending notifications
  Future<bool> hasPendingNotifications() async {
    final pending = await _notifications.pendingNotificationRequests();
    return pending.isNotEmpty;
  }

  /// Get list of pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // ============================================================================
  // DEBUG / TESTING METHODS
  // ============================================================================

  /// Send a test notification immediately (for testing purposes)
  /// This shows a random fun fact notification right away
  /// Returns the notification content for display (useful for simulator testing)
  Future<String?> sendTestNotification() async {
    final funFact = _getRandomFunFact();
    if (funFact == null) return null;

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      styleInformation: BigTextStyleInformation(funFact.body),
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // Ensure notification shows even when app is in foreground
      interruptionLevel: InterruptionLevel.active,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      9999, // Test notification ID
      funFact.title,
      funFact.body,
      details,
    );

    // Return content for simulator preview
    return '${funFact.title}\n\n${funFact.body}';
  }

  /// Schedule a test notification for 10 seconds from now
  Future<void> scheduleTestNotification() async {
    final funFact = _getRandomFunFact();
    if (funFact == null) return;

    final scheduledDate = DateTime.now().add(const Duration(seconds: 10));

    await _scheduleNotification(
      id: 9998, // Test scheduled notification ID
      title: funFact.title,
      body: funFact.body,
      scheduledDate: scheduledDate,
    );
  }
}

/// Board information helper class
class _BoardInfo {
  final String name;
  final String cityName;
  final List<TileData> Function() generateTiles;

  _BoardInfo(this.name, this.cityName, this.generateTiles);
}

/// Fun fact notification content
class _FunFactNotification {
  final String title;
  final String body;

  _FunFactNotification({required this.title, required this.body});
}
