import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/duty_model.dart';

class LogReportScreen extends StatelessWidget {
  final List<Duty> duties;
  final String reportTitle;
  final String reportType; // 'sweeper' or 'classroom'

  const LogReportScreen({
    super.key, 
    required this.duties, 
    required this.reportTitle, 
    required this.reportType,
  });

  String _getCurrentDateTime() {
    final now = DateTime.now();
    final minute = now.minute.toString().padLeft(2, '0');
    return "${now.day}/${now.month}/${now.year} at ${now.hour}:$minute";
  }

  Future<void> _generateAndPrintPdf(BuildContext context) async {
    final doc = pw.Document();
    final timestamp = _getCurrentDateTime();

    // Sort data based on report type
    List<Duty> sortedDuties = List.from(duties);
    if (reportType == 'sweeper') {
      sortedDuties.sort((a, b) => (a.sweeperName ?? 'z').compareTo(b.sweeperName ?? 'z'));
    } else {
      sortedDuties.sort((a, b) => a.roomName.compareTo(b.roomName));
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(reportTitle, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Generated on: $timestamp', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
              pw.SizedBox(height: 24),
              pw.TableHelper.fromTextArray(
                context: context,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
                cellAlignment: pw.Alignment.centerLeft,
                data: <List<String>>[
                  // Dynamic Columns based on what the Admin selected
                  reportType == 'sweeper' 
                      ? ['Sweeper Name', 'Assigned Room', 'Current Status', 'Verified By']
                      : ['Classroom', 'Current Status', 'Assigned Sweeper', 'Faculty Incharge'],
                  
                  // Dynamic Rows
                  ...sortedDuties.map((duty) => reportType == 'sweeper'
                      ? [
                          duty.sweeperName?.toUpperCase() ?? 'UNASSIGNED',
                          duty.roomName,
                          duty.status.name.toUpperCase(),
                          duty.facultyName?.replaceAll('Incharge: ', '') ?? 'N/A'
                        ]
                      : [
                          duty.roomName,
                          duty.status.name.toUpperCase(),
                          duty.sweeperName?.toUpperCase() ?? 'UNASSIGNED',
                          duty.facultyName?.replaceAll('Incharge: ', '') ?? 'N/A'
                        ]),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: '${reportTitle.replaceAll(' ', '_')}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sort for the UI viewer as well
    List<Duty> sortedDuties = List.from(duties);
    if (reportType == 'sweeper') {
      sortedDuties.sort((a, b) => (a.sweeperName ?? 'z').compareTo(b.sweeperName ?? 'z'));
    } else {
      sortedDuties.sort((a, b) => a.roomName.compareTo(b.roomName));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      appBar: AppBar(
        title: Text(reportTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFFF3F4F8),
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Report generated locally at: ${_getCurrentDateTime()}', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: sortedDuties.length,
              itemBuilder: (context, index) {
                final duty = sortedDuties[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Highlight Sweeper OR Room based on the report type
                          Text(
                            reportType == 'sweeper' ? (duty.sweeperName?.toUpperCase() ?? 'UNASSIGNED') : duty.roomName, 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                          ),
                          const SizedBox(height: 4),
                          Text(
                            reportType == 'sweeper' 
                                ? 'Room: ${duty.roomName} • ${duty.facultyName?.replaceAll("Incharge: ", "") ?? "N/A"}'
                                : 'Sweeper: ${duty.sweeperName?.toUpperCase() ?? "N/A"} • ${duty.facultyName?.replaceAll("Incharge: ", "") ?? "N/A"}', 
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)
                          ),
                        ],
                      ),
                      Text(duty.status.name.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: duty.status == DutyStatus.verified ? Colors.green : Colors.orange)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _generateAndPrintPdf(context),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.picture_as_pdf_rounded),
        label: const Text('Download PDF', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}