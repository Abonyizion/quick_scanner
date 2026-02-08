import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';


/// MUST be top-level (not inside a class)
Future<String> generatePdfInBackground(Map<String, dynamic> data) async {
  final List<String> imagePaths = data['images'];
  final String outputDir = data['dir'];

  final pdf = pw.Document();

  for (final path in imagePaths) {
    final bytes = await File(path).readAsBytes();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginLeft: 6,
          marginTop: 10,
          marginRight: 6,
          marginBottom: 10,
        ),
        build: (context) {
          final pageWidth = context.page.pageFormat.availableWidth;
          final pageHeight = context.page.pageFormat.availableHeight;

          return pw.Center(
            child: pw.Image(
              pw.MemoryImage(bytes),
              width: pageWidth,
              height: pageHeight,
              fit: pw.BoxFit.cover,
            ),
          );
        },
      ),
    );


  }

  final outputPath =
      '$outputDir/scanned_${DateTime.now().millisecondsSinceEpoch}.pdf';

  await File(outputPath).writeAsBytes(await pdf.save());
  return outputPath;
}
