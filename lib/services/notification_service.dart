import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    // Inicializar timezone
    tz_data.initializeTimeZones();

    // Configurações para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configurações para iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Configurações gerais
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Inicializar plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Manipular resposta de notificação quando o app está em primeiro plano
        print('Notificação clicada: ${response.payload}');
      },
    );

    // Solicitar permissões no iOS
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // Agendar notificação diária para lembrar de registrar transações
  Future<void> scheduleDailyTransactionReminder(TimeOfDay time) async {
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Se o horário já passou hoje, agendar para amanhã
    final effectiveTime = scheduledTime.isBefore(now)
        ? scheduledTime.add(const Duration(days: 1))
        : scheduledTime;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'transaction_reminder_channel',
      'Lembretes de Transações',
      channelDescription: 'Lembretes diários para registrar transações',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      1, // ID único para esta notificação
      'Lembrete de Finanças',
      'Não se esqueça de registrar suas transações de hoje!',
      tz.TZDateTime.from(effectiveTime, tz.local),
      platformDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repetir diariamente
      payload: 'transaction_reminder',
    );
  }

  // Agendar notificação para metas de economia
  Future<void> scheduleSavingsGoalReminder(
      int goalId, String goalTitle, DateTime deadline) async {
    // Agendar para uma semana antes do prazo
    final reminderDate = deadline.subtract(const Duration(days: 7));
    
    // Se a data já passou, não agendar
    if (reminderDate.isBefore(DateTime.now())) {
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'savings_goal_channel',
      'Lembretes de Metas',
      channelDescription: 'Lembretes para metas de economia',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      100 + goalId, // ID único baseado no ID da meta
      'Meta: $goalTitle',
      'Falta apenas uma semana para atingir sua meta! Verifique seu progresso.',
      tz.TZDateTime.from(reminderDate, tz.local),
      platformDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'goal_reminder_$goalId',
    );
  }

  // Agendar notificação para lembrete de pagamento de contas
  Future<void> scheduleBillPaymentReminder(
      int billId, String billTitle, DateTime dueDate) async {
    // Agendar para 3 dias antes do vencimento
    final reminderDate = dueDate.subtract(const Duration(days: 3));
    
    // Se a data já passou, não agendar
    if (reminderDate.isBefore(DateTime.now())) {
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'bill_payment_channel',
      'Lembretes de Contas',
      channelDescription: 'Lembretes para pagamento de contas',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      200 + billId, // ID único baseado no ID da conta
      'Pagamento: $billTitle',
      'Sua conta vence em 3 dias! Não se esqueça de pagar.',
      tz.TZDateTime.from(reminderDate, tz.local),
      platformDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'bill_reminder_$billId',
    );
  }

  // Enviar notificação imediata
  Future<void> showInstantNotification(
      String title, String body, String payload) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'instant_channel',
      'Notificações Instantâneas',
      channelDescription: 'Notificações instantâneas do aplicativo',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0, // ID único para esta notificação
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  // Cancelar todas as notificações
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Cancelar uma notificação específica
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
