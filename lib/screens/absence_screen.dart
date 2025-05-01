import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AbsenceScreen extends StatefulWidget {
  const AbsenceScreen({Key? key}) : super(key: key);

  @override
  State<AbsenceScreen> createState() => _AbsenceScreenState();
}

class _AbsenceScreenState extends State<AbsenceScreen> {
  List<String> teacherNames = [];
  final Map<String, TextEditingController> reasons = {};
  final Set<String> selected = {};
  bool isLoading = true;

  Future<void> fetchTeachers() async {
    final response = await Supabase.instance.client
        .from('timetables')
        .select('teacher_name');

    final data = response as List;
    final uniqueTeachers = data.map((e) => e['teacher_name'].toString()).toSet().toList();

    setState(() {
      teacherNames = uniqueTeachers;
      for (var name in uniqueTeachers) {
        reasons[name] = TextEditingController();
      }
      isLoading = false;
    });
  }

  Future<void> saveAbsences() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    for (var name in selected) {
      await Supabase.instance.client.from('absences').insert({
        'teacher_name': name,
        'date': today,
        'reason': reasons[name]?.text ?? '',
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الغيابات')),
    );

    setState(() {
      selected.clear();
      reasons.forEach((_, controller) => controller.clear());
    });
  }

  @override
  void initState() {
    super.initState();
    fetchTeachers();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل غياب المعلمين')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...teacherNames.map((name) => CheckboxListTile(
                title: Text(name),
                value: selected.contains(name),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      selected.add(name);
                    } else {
                      selected.remove(name);
                    }
                  });
                },
                subtitle: selected.contains(name)
                    ? TextField(
                        controller: reasons[name],
                        decoration: const InputDecoration(
                          hintText: 'سبب الغياب (اختياري)',
                        ),
                      )
                    : null,
              )),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: saveAbsences,
            child: const Text('حفظ الغيابات'),
          ),
        ],
      ),
    );
  }
}
