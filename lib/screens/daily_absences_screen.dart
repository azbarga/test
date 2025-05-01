
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class DailyAbsencesScreen extends StatefulWidget {
  const DailyAbsencesScreen({super.key});

  @override
  State<DailyAbsencesScreen> createState() => _DailyAbsencesScreenState();
}

class _DailyAbsencesScreenState extends State<DailyAbsencesScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> absences = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchTodayAbsences();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> fetchTodayAbsences() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    try {
      final data = await supabase
          .from('absences')
          .select('teacher_id, date, reason, teachers(name), lesson_time')
          .eq('date', today)
          .order('date');

      setState(() {
        absences = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      print('خطأ أثناء جلب الغيابات: \$e');
      setState(() => loading = false);
    }
  }

  Future<void> scheduleNotification(DateTime lessonTime, String teacherName, String lessonNumber) async {
    final timeDifference = lessonTime.subtract(const Duration(minutes: 5));  // قبل 5 دقائق من الحصة

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'غائب اليوم',
      'المعلم $teacherName غائب، الحصة القادمة رقم $lessonNumber فارغة. الرجاء إدخال معلم بديل.',
      timeDifference,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'absence_channel_id',
          'غياب المعلم',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'item x',
    );
  }

  Future<void> exportToExcel({bool share = false}) async {
    final excel = Excel.createExcel();
    final sheet = excel['الغيابات'];
    sheet.appendRow(['التاريخ', 'اسم المعلم', 'سبب الغياب']);

    for (var absence in absences) {
      final name = (absence['teachers'] != null)
          ? absence['teachers']['name'] ?? 'غير معروف'
          : 'غير معروف';
      final reason = absence['reason'] ?? '---';
      final date = absence['date'] ?? '';
      sheet.appendRow([date, name, reason]);
    }

    final fileBytes = excel.encode();
    if (fileBytes != null) {
      final filePath = await FileSaver.instance.saveFile(
        name: 'تقرير_الغيابات',
        bytes: Uint8List.fromList(fileBytes),
        ext: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );

      if (share && filePath != null) {
        Share.shareFiles([filePath], text: 'تقرير الغيابات اليومية');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تقرير الغيابات اليومية'),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'مشاركة Excel',
              onPressed: () => exportToExcel(share: true),
            ),
            IconButton(
              icon: const Icon(Icons.table_view),
              tooltip: 'تصدير Excel',
              onPressed: () => exportToExcel(share: false),
            ),
          ],
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : absences.isEmpty
                ? const Center(child: Text('لا يوجد غيابات مسجلة اليوم'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: absences.length,
                    itemBuilder: (context, index) {
                      final absence = absences[index];
                      final teacherName = (absence['teachers'] != null)
                          ? absence['teachers']['name'] ?? 'غير معروف'
                          : 'غير معروف';
                      final reason = absence['reason'] ?? '---';
                      final date = absence['date'];
                      final lessonTime = DateTime.parse(absence['lesson_time']);
                      final lessonNumber = absence['lesson_number'].toString();

                      // Schedule notification before the lesson
                      scheduleNotification(lessonTime, teacherName, lessonNumber);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(teacherName),
                          subtitle: Text('السبب: $reason'),
                          trailing: Text(date),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
