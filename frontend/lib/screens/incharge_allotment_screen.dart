// lib/screens/incharge_allotment_screen.dart
import 'package:flutter/material.dart';
import '../models/duty_model.dart';

class InchargeAllotmentScreen extends StatefulWidget {
  const InchargeAllotmentScreen({super.key});

  @override
  State<InchargeAllotmentScreen> createState() => _InchargeAllotmentScreenState();
}

class _InchargeAllotmentScreenState extends State<InchargeAllotmentScreen> {
  // MOCK DATA for Faculty Allotment
  final List<Duty> _facultyDuties = [
    Duty(id: '101', roomName: 'CSE Lab 1', department: 'Incharge: Prof. Suresh', status: DutyStatus.pending),
    Duty(id: '102', roomName: 'IoT Lab', department: 'Incharge: Prof. Anita', status: DutyStatus.pending),
    Duty(id: '103', roomName: 'Classroom 301', department: 'Incharge: Prof. Karthik', status: DutyStatus.pending),
  ];

  List<Duty> _facultyPreset1 = [];

  void _deleteAllotment(String id) {
    setState(() => _facultyDuties.removeWhere((duty) => duty.id == id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Faculty allotment removed.'),
        backgroundColor: const Color(0xFFC62828),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _savePreset() {
    setState(() {
      _facultyPreset1 = _facultyDuties.map((d) => Duty(
        id: d.id, roomName: d.roomName, department: d.department, status: DutyStatus.pending,
      )).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Faculty Routine saved as Preset 1!'),
        backgroundColor: const Color(0xFF3949AB),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _loadPreset() {
    if (_facultyPreset1.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No preset saved yet.'),
          backgroundColor: const Color(0xFFC62828),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() {
      _facultyDuties.clear();
      _facultyDuties.addAll(
        _facultyPreset1.map((p) => Duty(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          roomName: p.roomName, department: p.department, status: DutyStatus.pending,
        )).toList(),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Faculty Preset 1 loaded!'),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showAllotDialog() {
    String selectedRoom = 'CSE Lab 1';
    String selectedFaculty = 'Prof. Suresh';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              child: Padding(
                padding: const EdgeInsets.all(26.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)]),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.school_rounded, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(child: Text('Allot Incharge', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRoom,
                      decoration: InputDecoration(
                        labelText: 'Select Room', filled: true, fillColor: const Color(0xFFF7F7FA),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                      items: const ['CSE Lab 1', 'CSE Lab 2', 'IoT Lab', 'Classroom 301', 'HOD Cabin']
                          .map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                      onChanged: (value) => setDialogState(() => selectedRoom = value!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedFaculty,
                      decoration: InputDecoration(
                        labelText: 'Select Faculty', filled: true, fillColor: const Color(0xFFF7F7FA),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                      items: const ['Prof. Suresh', 'Prof. Anita', 'Prof. Karthik', 'Prof. Meena']
                          .map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                      onChanged: (value) => setDialogState(() => selectedFaculty = value!),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A), foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () {
                              setState(() {
                                _facultyDuties.insert(0, Duty(
                                  id: DateTime.now().toString(),
                                  roomName: selectedRoom,
                                  department: 'Incharge: $selectedFaculty',
                                  status: DutyStatus.pending,
                                ));
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Allot', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F4F8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Faculty Allotment', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87, fontSize: 20)),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text('INCHARGE LIST', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 1)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _loadPreset, icon: const Icon(Icons.restore_rounded, size: 16), label: const Text('Load', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                TextButton.icon(
                  onPressed: _savePreset, icon: const Icon(Icons.save_rounded, size: 16), label: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemCount: _facultyDuties.length,
              itemBuilder: (context, index) {
                final duty = _facultyDuties[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.04), blurRadius: 10, offset: const Offset(0, 3))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(14)),
                        child: Icon(Icons.school_rounded, color: Colors.purple.shade400, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(duty.roomName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                            const SizedBox(height: 2),
                            Text(duty.department, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade300, size: 22),
                        onPressed: () => _deleteAllotment(duty.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAllotDialog,
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Allot Faculty', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}