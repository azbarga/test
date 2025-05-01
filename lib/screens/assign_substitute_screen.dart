
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:html' as html;

class AssignSubstituteScreen extends StatefulWidget {
  const AssignSubstituteScreen({super.key});

  @override
  State<AssignSubstituteScreen> createState() => _AssignSubstituteScreenState();
}

class _AssignSubstituteScreenState extends State<AssignSubstituteScreen> {
  final List<String> days = ['ראשון', 'שני', 'שלישי', 'רביעי', 'חמישי'];
  String selectedDay = 'ראשון';

  List<String> classNames = [];
  String? selectedClass;
  int? selectedPeriod;

  List<String> teacherNames = [];
  String? selectedSubstitute;
  String? originalTeacher;

  bool isLoading = false;

  Future<void> loadTeachersAndClasses() async {
    setState(() => isLoading = true);

    final timetable = await Supabase.instance.client
        .from('timetables')
        .select();

    final Set<String> allTeachers = {};
    final Set<String> allClasses = {};

    for (var row in timetable) {
      allTeachers.add(row['teacher_name']);
      allClasses.add(row['class_name']);
    }

    setState(() {
      teacherNames = allTeachers.toList()..sort();
      classNames = allClasses.toList()..sort();
      isLoading = false;
    });
  }

  Future<void> detectOriginalTeacher() async {
    if (selectedClass == null || selectedPeriod == null) return;

    final result = await Supabase.instance.client
        .from('timetables')
        .select()
        .eq('day', selectedDay)
        .eq('class_name', selectedClass)
        .eq('period_number', selectedPeriod);

    if (result is List && result.isNotEmpty) {
      setState(() {
        originalTeacher = result[0]['teacher_name'];
      });
    } else {
      setState(() {
        originalTeacher = null;
      });
    }
  }

  Future<void> assignSubstitute() async {
    if (selectedClass == null || selectedPeriod == null || selectedSubstitute == null || originalTeacher == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة جميع الحقول')),
      );
      return;
    }

    await Supabase.instance.client.from('substitutes').insert({
      'day': selectedDay,
      'class_name': selectedClass,
      'period_number': selectedPeriod,
      'original_teacher': originalTeacher,
      'substitute_teacher': selectedSubstitute,
    });

    final result = await Supabase.instance.client
        .from('teachers')
        .select('phone')
        .eq('name', selectedSubstitute)
        .maybeSingle();

    final phone = result?['phone'];
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد رقم جوال للمعلم البديل')),
      );
      return;
    }

    final message =
        'السلام عليكم، تم تعيينك كمعلم بديل في الحصة رقم ($selectedPeriod) لصف ($selectedClass) بسبب غياب المعلم ($originalTeacher). شكراً لتعاونك.';
    final encodedMsg = Uri.encodeComponent(message);
    final whatsappUrl = 'https://wa.me/$phone?text=$encodedMsg';

    html.window.open(whatsappUrl, '_blank');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تعيين المعلم البديل وتم فتح رابط WhatsApp ✅')),
    );

    setState(() {
      selectedClass = null;
      selectedPeriod = null;
      selectedSubstitute = null;
      originalTeacher = null;
    });
  }

  @override
  void initState() {
    super.initState();
    loadTeachersAndClasses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعيين معلم بديل')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  decoration: const InputDecoration(labelText: 'اليوم'),
                  items: days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (val) {
                    setState(() => selectedDay = val!);
                    detectOriginalTeacher();
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedClass,
                  decoration: const InputDecoration(labelText: 'الصف'),
                  items: classNames.map((cls) => DropdownMenuItem(value: cls, child: Text(cls))).toList(),
                  onChanged: (val) {
                    setState(() => selectedClass = val);
                    detectOriginalTeacher();
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: selectedPeriod,
                  decoration: const InputDecoration(labelText: 'رقم الحصة'),
                  items: List.generate(6, (i) => i + 1).map((p) => DropdownMenuItem(value: p, child: Text('الحصة $p'))).toList(),
                  onChanged: (val) {
                    setState(() => selectedPeriod = val);
                    detectOriginalTeacher();
                  },
                ),
                const SizedBox(height: 12),
                if (originalTeacher != null)
                  Text('المعلم الأصلي: $originalTeacher', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedSubstitute,
                  decoration: const InputDecoration(labelText: 'المعلم البديل'),
                  items: teacherNames.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) {
                    setState(() => selectedSubstitute = val);
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: assignSubstitute,
                  child: const Text('تأكيد التعيين'),
                ),
              ],
            ),
    );
  }
}
