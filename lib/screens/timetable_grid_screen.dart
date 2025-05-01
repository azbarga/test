
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TimetableGridScreen extends StatefulWidget {
  const TimetableGridScreen({Key? key}) : super(key: key);

  @override
  State<TimetableGridScreen> createState() => _TimetableGridScreenState();
}

class _TimetableGridScreenState extends State<TimetableGridScreen> {
  final List<String> days = ['ראשון', 'שני', 'שלישי', 'רביעי', 'חמישי'];
  String selectedDay = 'ראשון';

  List<String> classNames = [];
  List<int> periods = [1, 2, 3, 4, 5, 6];
  Map<String, Map<int, String>> timetable = {};
  bool isLoading = true;

  Future<void> fetchTimetable() async {
    setState(() => isLoading = true);

    try {
      final response = await Supabase.instance.client
          .from('timetables')
          .select()
          .eq('day', selectedDay);

      print("استجابة Supabase: \$response");

      final data = response is List ? response : [];

      final Map<String, Map<int, String>> map = {};
      final Set<String> classSet = {};

      for (var row in data) {
        final className = row['class_name'];
        final period = row['period_number'];
        final subject = row['subject'];
        final teacher = row['teacher_name'];

        map.putIfAbsent(className, () => {});
        map[className]![period] = '\$subject\n\$teacher';
        classSet.add(className);
      }

      setState(() {
        classNames = classSet.toList()..sort();
        timetable = map;
        isLoading = false;
      });
    } catch (e) {
      print('حدث خطأ أثناء جلب البيانات: \$e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTimetable();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جدول الحصص اليومي'),
        actions: [
          DropdownButton<String>(
            value: selectedDay,
            dropdownColor: Colors.white,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedDay = value;
                });
                fetchTimetable();
              }
            },
            items: days.map((day) {
              return DropdownMenuItem(value: day, child: Text(day));
            }).toList(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                border: TableBorder.all(),
                defaultColumnWidth: const FixedColumnWidth(120.0),
                children: [
                  TableRow(
                    children: [
                      const TableCell(child: Center(child: Text('رقم الحصة'))),
                      ...classNames.map((cls) =>
                          TableCell(child: Center(child: Text(cls)))),
                    ],
                  ),
                  ...periods.map((p) {
                    return TableRow(
                      children: [
                        TableCell(child: Center(child: Text('\$p'))),
                        ...classNames.map((cls) {
                          final cell = timetable[cls]?[p] ?? '';
                          return TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(cell, textAlign: TextAlign.center),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
