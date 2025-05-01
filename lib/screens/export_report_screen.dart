
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

class ExportReportScreen extends StatelessWidget {
  const ExportReportScreen({super.key});

  Future<void> _exportExcel(BuildContext context) async {
    try {
      if (!kIsWeb) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⚠️ تم رفض صلاحية التخزين')),
          );
          return;
        }
      }

      // توليد تجريبي
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📊 تم توليد تقرير Excel (تجريبي)')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: \$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تصدير تقرير الحصص')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'اختر نوع التقرير:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.table_chart),
              label: const Text('تصدير Excel'),
              onPressed: () => _exportExcel(context),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('تصدير PDF'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('📄 توليد PDF لم يُفعّل بعد')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
