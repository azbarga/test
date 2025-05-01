import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MarkAbsenceScreen extends StatefulWidget {
  const MarkAbsenceScreen({super.key});

  @override
  State<MarkAbsenceScreen> createState() => _MarkAbsenceScreenState();
}

class _MarkAbsenceScreenState extends State<MarkAbsenceScreen> {
  final supabase = Supabase.instance.client;
  Map<String, bool> selectedTeachers = {};
  Map<String, String> reasons = {};
  List<Map<String, dynamic>> teachers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchTeachers();
  }

  Future<void> fetchTeachers() async {
    final response = await supabase.from('teachers').select();
    setState(() {
      teachers = List<Map<String, dynamic>>.from(response);
      loading = false;
    });
  }

  Future<void> saveAbsences() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    try {
      for (var teacher in selectedTeachers.entries) {
        if (teacher.value) {
          print("Trying to insert absence for teacher_id: \${teacher.key}");

          final response = await supabase.from('absences').insert({
            'teacher_id': teacher.key,
            'date': today,
            'reason': reasons[teacher.key] ?? '',
          });

          print("Response: \$response");
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الغيابات بنجاح')),
      );
      Navigator.pop(context);
    } catch (e, stack) {
      print("❌ Exception during absence save: \$e");
      print("🔍 StackTrace: \$stack");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الحفظ: \$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تسجيل غياب المعلمين')),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ...teachers.map((teacher) {
                    final id = teacher['id'] as String;
                    final name = teacher['name'] as String;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          title: Text(name),
                          value: selectedTeachers[id] ?? false,
                          onChanged: (val) {
                            setState(() {
                              selectedTeachers[id] = val ?? false;
                            });
                          },
                        ),
                        if (selectedTeachers[id] == true)
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'سبب الغياب (اختياري)',
                              ),
                              onChanged: (val) => reasons[id] = val,
                            ),
                          ),
                        const Divider(),
                      ],
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: saveAbsences,
                    child: const Text('تأكيد الغياب'),
                  ),
                ],
              ),
      ),
    );
  }
}
