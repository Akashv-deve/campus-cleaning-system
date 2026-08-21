import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/duty_model.dart';

class LogReportScreen extends StatefulWidget {
  final List<Duty> duties;
  final String reportTitle;
  final String reportType; // 'sweeper' or 'classroom'

  const LogReportScreen({
    super.key, 
    required this.duties, 
    required this.reportTitle, 
    required this.reportType,
  });

  @override
  State<LogReportScreen> createState() => _LogReportScreenState();
}

class _LogReportScreenState extends State<LogReportScreen> {
  String _selectedEntity = 'All';
  List<String> _filterOptions = ['All'];

  @override
  void initState() {
    super.initState();
    _generateFilterOptions();
  }

  // Automatically finds every custom name in the database for the dropdown
  void _generateFilterOptions() {
    Set<String> uniqueNames = {};
    for (var duty in widget.duties) {
      if (widget.reportType == 'sweeper') {
        uniqueNames.add(duty.sweeperName?.toUpperCase() ?? 'UNASSIGNED');
      } else {
        uniqueNames.add(duty.roomName);
      }
    }
    setState(() {
      _filterOptions = ['All', ...uniqueNames.toList()..sort()];
    });
  }

  // Filters the list so you can view an individual page
  List<Duty> get _filteredDuties {
    List<Duty> filtered = List.from(widget.duties);
    if (_selectedEntity != 'All') {
      if (widget.reportType == 'sweeper') {
        filtered = filtered.where((d) => (d.sweeperName?.toUpperCase() ?? 'UNASSIGNED') == _selectedEntity).toList();
      } else {
        filtered = filtered.where((d) => d.roomName == _selectedEntity).toList();
      }
    }
    
    // Sort the final result
    if (widget.reportType == 'sweeper') {
      filtered.sort((a, b) => (a.sweeperName ?? 'z').compareTo(b.sweeperName ?? 'z'));
    } else {
      filtered.sort((a, b) => a.roomName.compareTo(b.roomName));
    }
    return filtered;
  }

  String _getCurrentDateTime() {
    final now = DateTime.now();
    final minute = now.minute.toString().padLeft(2, '0');
    return "${now.day}/${now.month}/${now.year} at ${now.hour}:$minute";
  }

  Future<void> _generateAndPrintPdf(BuildContext context) async {
    final doc = pw.Document();
    final timestamp = _getCurrentDateTime();
    final dataList = _filteredDuties; // Only prints the filtered individual!

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                _selectedEntity == 'All' ? widget.reportTitle : '${widget.reportTitle}: $_selectedEntity', 
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)
              ),
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
                  widget.reportType == 'sweeper' 
                      ? ['Sweeper Name', 'Assigned Room', 'Status', 'Verified By']
                      : ['Classroom', 'Status', 'Assigned Sweeper', 'Faculty Incharge'],
                  
                  ...dataList.map((duty) => widget.reportType == 'sweeper'
                      ? [
                          duty.sweeperName?.toUpperCase() ?? 'UNASSIGNED',
                          duty.roomName,
                          duty.status == DutyStatus.verified ? 'Done at ${duty.completedTime ?? ""}' : duty.status.name.toUpperCase(),
                          duty.facultyName?.replaceAll('Incharge: ', '') ?? 'N/A'
                        ]
                      : [
                          duty.roomName,
                          duty.status == DutyStatus.verified ? 'Verified at ${duty.verifiedTime ?? ""}' : duty.status.name.toUpperCase(),
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
      name: '${_selectedEntity}_Log.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayData = _filteredDuties;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      appBar: AppBar(
        title: Text(widget.reportTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFFF3F4F8),
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // THE INDIVIDUAL FILTER DROPDOWN
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.filter_list_rounded, color: Color(0xFF3949AB)),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedEntity,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: _filterOptions.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                      onChanged: (val) => setState(() => _selectedEntity = val!),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Showing ${displayData.length} records • Time: ${_getCurrentDateTime()}', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: displayData.length,
              itemBuilder: (context, index) {
                final duty = displayData[index];
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
                          Text(
                            widget.reportType == 'sweeper' ? (duty.sweeperName?.toUpperCase() ?? 'UNASSIGNED') : duty.roomName, 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.reportType == 'sweeper' 
                                ? 'Room: ${duty.roomName} • Completed: ${duty.completedTime ?? "Pending"}'
                                : 'Sweeper: ${duty.sweeperName?.toUpperCase() ?? "N/A"} • Verified: ${duty.verifiedTime ?? "Pending"}', 
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
        label: const Text('Download Individual PDF', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}