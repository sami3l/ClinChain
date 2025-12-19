import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service for managing local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
      linux: linuxSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap - could navigate to specific screen
    // For now, just log it
    print('Notification tapped: ${response.payload}');
  }

  /// Show a notification for a new lot created
  Future<void> notifyLotCreated(String medName, int quantity) async {
    await _showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '✅ Nouveau lot créé',
      body: '$medName - $quantity unités',
      payload: 'lot_created',
    );
  }

  /// Show a notification for lot validation
  Future<void> notifyLotValidated(String medName) async {
    await _showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🎉 Lot validé',
      body: 'La réception de $medName a été validée',
      payload: 'lot_validated',
    );
  }

  /// Show a notification for lot withdrawal
  Future<void> notifyLotWithdrawal(String medName, int quantity) async {
    await _showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '📦 Retrait effectué',
      body: '$quantity unités de $medName ont été retirées',
      payload: 'lot_withdrawal',
    );
  }

  /// Show a notification for order placed
  Future<void> notifyOrderPlaced(String medName) async {
    await _showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🛒 Commande envoyée',
      body: 'Commande de $medName enregistrée',
      payload: 'order_placed',
    );
  }

  /// Show a notification for pending validation (reminder)
  Future<void> notifyPendingValidation(int count) async {
    await _showNotification(
      id: 999, // Fixed ID so it updates instead of creating multiple
      title: '⏳ Validation en attente',
      body: '$count lot${count > 1 ? 's' : ''} en attente de validation',
      payload: 'pending_validation',
    );
  }

  /// Generic notification method
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'med_lot_channel',
      'Medication Lots',
      channelDescription: 'Notifications for medication lot management',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const linuxDetails = LinuxNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
      linux: linuxDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Request notification permissions (mainly for iOS)
  Future<bool> requestPermissions() async {
    if (!_initialized) {
      await initialize();
    }

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    // Android 13+ requires runtime permission
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    // iOS requires permission
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    return true;
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
