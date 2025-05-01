import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImportExcelScreen extends StatefulWidget {
  const ImportExcelScreen({Key? key}) : super(key: key);

  @override
  State<ImportExcelScreen> createState() => _ImportExcelScreenState();
}

class _ImportExcelScreenState extends State<ImportExcelScreen> {
  bool isLoading = false;

  Future<void> pickAndUploadExcel() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']);
    if (result == null || result.files.single.bytes == null) return;

    setState(() => isLoading = true);

    final excel = Excel.decodeBytes(result.files.single.bytes!);
    final sheet = excel.tables.values.first;
    final day = 'ראשון';

    final headers = sheet!.rows[0];
    final periodColumnIndex = 0;

    for (int rowIndex = 1; rowIndex < sheet.rows.length; rowIndex++) {
      final row = sheet.rows[rowIndex];
      final periodCell = row[periodColumnIndex];
      final periodNumber = int.tryParse(periodCell?.value.toString().trim() ?? '');

      if (periodNumber == null) continue;

      for (int colIndex = 1; colIndex < row.length; colIndex++) {
        final className = headers[colIndex]?.value.toString().trim();
        final cellValue = row[colIndex]?.value?.toString().trim();

        if (cellValue == null || className == null || cellValue.isEmpty) continue;

        final parts = cellValue.split('\n');
        final subject = parts.isNotEmpty ? parts[0].trim() : '';
        final teacherName = parts.length > 1 ? parts[1].trim() : '';

        if (subject.isEmpty || teacherName.isEmpty) continue;

        await Supabase.instance.client.from('timetables').insert({
          'day': day,
          'class_name': className,
          'period_number': periodNumber,
          'subject': subject,
          'teacher_name': teacherName,
        });
      }
    }

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم استيراد الجدول بنجاح إلى Supabase')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('استيراد جدول الحصص')),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: pickAndUploadExcel,
                child: const Text('اختر ملف Excel'),
              ),
      ),
    );
  }
}
