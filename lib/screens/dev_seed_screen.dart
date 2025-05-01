import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DevSeedScreen extends StatelessWidget {
  const DevSeedScreen({super.key});

  Future<void> seedTimetable() async {
    const day = 'ראשון';
    final classNames = ['ז\' 1', 'ח\' 1', 'ט\' 1'];
    final subjects = ['ערבית', 'עברית', 'אנגלית', 'מתמטיקה'];
    final teachers = ['חולוד הואשל', 'אבי סבאח', 'רו אבראהים', 'נגאח'];

    for (final className in classNames) {
      for (int period = 1; period <= 6; period++) {
        final subject = subjects[period % subjects.length];
        final teacher = teachers[period % teachers.length];

        await Supabase.instance.client.from('timetables').insert({
          'day': day,
          'class_name': className,
          'period_number': period,
          'subject': subject,
          'teacher_name': teacher,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('توليد بيانات تجريبية')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await seedTimetable();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم توليد البيانات بنجاح ✅')),
            );
          },
          child: const Text('زرع بيانات جدول حصة'),
        ),
      ),
    );
  }
}
