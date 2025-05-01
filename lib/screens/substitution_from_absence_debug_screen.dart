
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class SubstitutionFromAbsenceDebugScreen extends StatefulWidget {
  const SubstitutionFromAbsenceDebugScreen({super.key});

  @override
  State<SubstitutionFromAbsenceDebugScreen> createState() => _SubstitutionFromAbsenceDebugScreenState();
}

class _SubstitutionFromAbsenceDebugScreenState extends State<SubstitutionFromAbsenceDebugScreen> {
  List<Map<String, dynamic>> pendingSubstitutions = [];
  List<String> allTeachers = [];
  List absences = [];
  List timetable = [];
  List<String> absentNames = [];
  List filtered = [];
  String errorMessage = '';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSubstitutionNeeds();
  }

  Future<void> fetchSubstitutionNeeds() async {
    setState(() => isLoading = true);

    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final absencesResult = await Supabase.instance.client
          .from('absences')
          .select()
          .eq('date', today)
          .timeout(const Duration(seconds: 10));

      final timetableResult = await Supabase.instance.client
          .from('timetables')
          .select()
          .timeout(const Duration(seconds: 10));

      final teacherRes = await Supabase.instance.client
          .from('teachers')
          .select('name')
          .timeout(const Duration(seconds: 10));

      absences = absencesResult;
      timetable = timetableResult;

      absentNames = absences.map((e) => e['teacher_name']).toList().cast<String>();
      final dayName = 'ראשון'; // ثابت مؤقت
      filtered = timetable.where((row) =>
          absentNames.contains(row['teacher']) &&
          row['day'] == dayName
      ).toList();

      final List<Map<String, dynamic>> result = [];
      for (var row in filtered) {
        result.add({
          'class_name': row['class_name'],
          'period_number': row['period_number'],
          'original_teacher': row['teacher'],
        });
      }

      final List<String> teacherList = teacherRes.map((t) => t['name']).toList().cast<String>();

      print('📌 عدد الغيابات: \${absences.length}');
print('📌 أسماء الغائبين: \$absentNames');
print('📌 عدد الحصص المتأثرة: \${filtered.length}');
setState(() {
        pendingSubstitutions = result;
        allTeachers = teacherList;
        isLoading = false;
      });
    } catch (e) {
      print('📌 عدد الغيابات: \${absences.length}');
print('📌 أسماء الغائبين: \$absentNames');
print('📌 عدد الحصص المتأثرة: \${filtered.length}');
setState(() {
        errorMessage = 'خطأ أثناء تحميل البيانات: \$e';
        isLoading = false;
      });
    }
  }

  Widget infoBox(String title, dynamic content) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text("\$title:\n\$content"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تصحيح الحصص')),
      body: Builder(
        builder: (context) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (errorMessage.isNotEmpty) {
            return Center(child: Text(errorMessage));
          } else if (absences.isEmpty) {
            return const Center(child: Text('⚠️ لا يوجد غيابات لهذا اليوم'));
          } else if (pendingSubstitutions.isEmpty) {
            return const Center(child: Text('✅ لا توجد حصص تحتاج معلم بديل'));
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  infoBox('عدد الغيابات', absences.length),
                  infoBox('المعلمين الغائبين', absentNames.join(', ')),
                  infoBox('عدد جميع الحصص', timetable.length),
                  infoBox('عدد الحصص المتأثرة', filtered.length),
                  infoBox('عدد المعلمين الكلي', allTeachers.length),
                  const SizedBox(height: 20),
                  const Text('📌 الحصص التي تحتاج بديل:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...pendingSubstitutions.map((row) => ListTile(
                        title: Text('صف ${row['class_name']} - حصة ${row['period_number']}'),
                        subtitle: Text('معلم غائب: ${row['original_teacher']}'),
                      )),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
