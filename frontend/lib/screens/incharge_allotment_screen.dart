// lib/screens/incharge_allotment_screen.dart
import 'package:flutter/material.dart';
import '../models/duty_model.dart';
import '../services/api_service.dart';

class InchargeAllotmentScreen extends StatefulWidget {
  const InchargeAllotmentScreen({super.key});

  @override
  State<InchargeAllotmentScreen> createState() => _InchargeAllotmentScreenState();
}

class _InchargeAllotmentScreenState extends State<InchargeAllotmentScreen> {
  // --- STATE VARIABLES ---
  List<Duty> _facultyDuties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllotments();
  }

  // --- API FUNCTIONS ---
  Future<void> _fetchAllotments() async {
    setState(() => _isLoading = true);
    try {
      // NOTE: assumes ApiService.getAllDuties() returns Future<List<Duty>>.
      // If your incharge list should be scoped to a department instead,
      // swap this for ApiService.getDutiesByDepartment('CSE') as used
      // elsewhere in the app.
      final allDuties = await ApiService.getAllDuties();
      if (!mounted) return;
      setState(() {
        _facultyDuties = allDuties;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching allotments: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not load allotments. Pull to refresh to retry.'),
          backgroundColor: const Color(0xFFC62828),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _deleteAllotment(String id) {
    // NOTE: your api_service.dart doesn't expose a delete endpoint yet
    // (no DELETE /api/duties/{id} method), so this stays local-only for
    // now, same as your original code — it won't persist across a refetch.
    // Add a `deleteDuty(String id)` method to ApiService (backed by a
    // DELETE route on the Spring Boot side) and I can wire this up to
    // actually remove it from MongoDB too.
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

  void _showAllotDialog() {
    String selectedRoom = 'CSE Lab 1';
    String selectedFaculty = 'Prof. Suresh';
    bool isSubmitting = false;
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
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
                        const Expanded(
                          child: Text('Allot Incharge', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRoom,
                      decoration: InputDecoration(
                        labelText: 'Select Room',
                        filled: true,
                        fillColor: const Color(0xFFF7F7FA),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                      items: const ['CSE Lab 1', 'CSE Lab 2', 'IoT Lab', 'Classroom 301', 'HOD Cabin']
                          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                          .toList(),
                      onChanged: isSubmitting ? null : (value) => setDialogState(() => selectedRoom = value!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedFaculty,
                      decoration: InputDecoration(
                        labelText: 'Select Faculty',
                        filled: true,
                        fillColor: const Color(0xFFF7F7FA),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                      items: const ['Prof. Suresh', 'Prof. Anita', 'Prof. Karthik', 'Prof. Meena']
                          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                          .toList(),
                      onChanged: isSubmitting ? null : (value) => setDialogState(() => selectedFaculty = value!),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    setDialogState(() => isSubmitting = true);
                                    try {
                                      // ApiService.createDuty takes positional
                                      // (roomName, department) — the backend
                                      // defaults status to PENDING itself.
                                      await ApiService.createDuty(
                                        selectedRoom,
                                        'Incharge: $selectedFaculty',
                                      );
                                      if (!dialogContext.mounted) return;
                                      Navigator.pop(dialogContext);
                                      await _fetchAllotments();
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text('$selectedFaculty allotted to $selectedRoom.'),
                                          backgroundColor: const Color(0xFF2E7D32),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      );
                                    } catch (e) {
                                      debugPrint("Allotment failed: $e");
                                      setDialogState(() => isSubmitting = false);
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: const Text('Could not allot faculty. Please try again.'),
                                          backgroundColor: const Color(0xFFC62828),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      );
                                    }
                                  },
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Text('Allot', style: TextStyle(fontWeight: FontWeight.bold)),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _fetchAllotments,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B9A)))
          : RefreshIndicator(
              onRefresh: _fetchAllotments,
              color: const Color(0xFF6A1B9A),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        Text(
                          'INCHARGE LIST',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 1),
                        ),
                        const Spacer(),
                        Text('${_facultyDuties.length} total', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _facultyDuties.isEmpty
                        ? ListView(
                            // ListView (not a bare Center) so RefreshIndicator's
                            // pull-to-refresh still works on an empty list.
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                              Center(
                                child: Text(
                                  'No faculty allotted yet.\nTap "Allot Faculty" to add one.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            itemCount: _facultyDuties.length,
                            itemBuilder: (context, index) {
                              final duty = _facultyDuties[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
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