
import 'package:flutter/material.dart';
import 'export_report_screen.dart';

class SubstitutionFromAbsenceScreen extends StatefulWidget {
  const SubstitutionFromAbsenceScreen({Key? key}) : super(key: key);

  @override
  State<SubstitutionFromAbsenceScreen> createState() => _SubstitutionFromAbsenceScreenState();
}

class _SubstitutionFromAbsenceScreenState extends State<SubstitutionFromAbsenceScreen> {
  final List<Map<String, dynamic>> periodsNeedingSubstitute = [
    {
      'className': '1 ب',
      'teacher': 'أ. خالد',
      'periodNumber': 2,
      'day': 'الأحد',
    },
    {
      'className': 'ثاني ج',
      'teacher': 'أ. منى',
      'periodNumber': 4,
      'day': 'الاثنين',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حصص تحتاج معلم بديل'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'تصدير تقرير',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExportReportScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: periodsNeedingSubstitute.length,
          itemBuilder: (context, index) {
            final period = periodsNeedingSubstitute[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("📚 الصف: ${period['className']}", style: TextStyle(fontSize: 18)),
                    Text("🧑‍🏫 المعلم الغائب: ${period['teacher']}", style: TextStyle(fontSize: 18)),
                    Text("🔢 رقم الحصة: ${period['periodNumber']}", style: TextStyle(fontSize: 18)),
                    Text("🗓️ اليوم: ${period['day']}", style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: نافذة تعيين معلم بديل
                        },
                        child: const Text('تعيين معلم بديل'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
