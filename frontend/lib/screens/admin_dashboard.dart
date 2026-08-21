// lib/screens/admin_dashboard.dart
import 'package:flutter/material.dart';
import '../models/duty_model.dart';
import 'incharge_allotment_screen.dart';
import '../services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _selectedFilter = 'All';
  
  // --- STATE VARIABLES ---
  List<Duty> _allDuties = []; // Now starts empty!
  bool _isLoading = true;
  List<Duty> _dutyPreset1 = [];

  @override
  void initState() {
    super.initState();
    _fetchDuties();
  }

  // --- API FUNCTIONS ---
  Future<void> _fetchDuties() async {
    try {
      final fetchedDuties = await ApiService.getAllDuties();
      setState(() {
        // Reverse so the newest duties appear at the top of the list
        _allDuties = fetchedDuties.reversed.toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching duties: $e");
      setState(() => _isLoading = false);
    }
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/');
  }

  Color _getStatusColor(DutyStatus status) {
    switch (status) {
      case DutyStatus.pending: return const Color(0xFFEF6C00);
      case DutyStatus.completed: return const Color(0xFF1565C0);
      case DutyStatus.verified: return const Color(0xFF2E7D32);
      case DutyStatus.rejected: return const Color(0xFFC62828);
    }
  }

  // --- PRESET & DELETE FUNCTIONS ---
  Future<void> _deleteDuty(String dutyId) async {
    try {
      // Tell MongoDB to delete it forever
      await ApiService.deleteDuty(dutyId);
      
      // Remove it from the screen
      setState(() => _allDuties.removeWhere((duty) => duty.id == dutyId));
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Row(children: [Icon(Icons.delete_outline_rounded, color: Colors.white), SizedBox(width: 10), Text('Duty permanently deleted.')]), backgroundColor: const Color(0xFFC62828), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), duration: const Duration(seconds: 2)),
      );
    } catch (e) {
      debugPrint("Delete failed: $e");
    }
  }

  void _savePreset() {
    setState(() => _dutyPreset1 = _allDuties.map((duty) => Duty(id: duty.id, roomName: duty.roomName, department: duty.department, status: DutyStatus.pending)).toList());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Row(children: [Icon(Icons.save_rounded, color: Colors.white), SizedBox(width: 10), Text('Routine saved as Duty Preset 1!')]), backgroundColor: const Color(0xFF3949AB), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );
  }

  void _loadPreset() {
    if (_dutyPreset1.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('No preset saved yet. Save a preset first!'), backgroundColor: const Color(0xFFC62828), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
      return;
    }
    setState(() {
      _allDuties.clear();
      _allDuties.addAll(_dutyPreset1.map((preset) => Duty(id: DateTime.now().microsecondsSinceEpoch.toString() + preset.roomName, roomName: preset.roomName, department: preset.department, status: DutyStatus.pending)).toList());
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Row(children: [Icon(Icons.restore_rounded, color: Colors.white), SizedBox(width: 10), Text('Duty Preset 1 loaded successfully!')]), backgroundColor: const Color(0xFF2E7D32), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }

  // --- PDF REPORT FUNCTION ---
  void _showReportSelector(BuildContext context) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 24),
              const Row(children: [Icon(Icons.analytics_rounded, color: Color(0xFF3949AB), size: 28), SizedBox(width: 12), Text('Generate Reports', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87))]),
              const SizedBox(height: 24),
              _buildReportOption(context, title: 'Sweeper Log Report', subtitle: 'Daily attendance & completion stats', icon: Icons.person_search_rounded, color: const Color(0xFF00897B)),
              const SizedBox(height: 12),
              _buildReportOption(context, title: 'Classroom Status Log', subtitle: 'Verification history by faculty', icon: Icons.meeting_room_rounded, color: const Color(0xFFE53935)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportOption(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color}) {
    return InkWell(
      onTap: () { Navigator.pop(context); _simulatePdfDownload(title); },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5), borderRadius: BorderRadius.circular(16), color: color.withValues(alpha: 0.05)),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 26)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)), const SizedBox(height: 2), Text(subtitle, style: TextStyle(color: Colors.grey.shade700, fontSize: 13))])),
            Icon(Icons.download_rounded, color: color),
          ],
        ),
      ),
    );
  }

  void _simulatePdfDownload(String reportName) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)), const SizedBox(width: 16), Text('Generating $reportName...')]), backgroundColor: const Color(0xFF3949AB), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), duration: const Duration(seconds: 2)));
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Row(children: [Icon(Icons.check_circle_rounded, color: Colors.white), SizedBox(width: 12), Text('PDF Saved to Downloads Folder!')]), backgroundColor: const Color(0xFF2E7D32), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), duration: const Duration(seconds: 3)));
  }

  // --- LIVE ASSIGN DIALOG ---
  void _showAssignDutyDialog() {
    String selectedRoom = 'CSE Lab 1';
    String selectedSweeper = 'Kumar';
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF3949AB), Color(0xFF5C6BC0)]), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.add_task_rounded, color: Colors.white)), const SizedBox(width: 16), const Expanded(child: Text('Assign New Duty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))]),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(initialValue: selectedRoom, decoration: InputDecoration(labelText: 'Select Room', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)), items: const ['CSE Lab 1', 'CSE Lab 2', 'IoT Lab', 'Classroom 301', 'HOD Cabin'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (value) => setDialogState(() => selectedRoom = value!)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(initialValue: selectedSweeper, decoration: InputDecoration(labelText: 'Assign Sweeper', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)), items: const ['Kumar', 'Rajesh', 'Lakshmi', 'Meena'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (value) => setDialogState(() => selectedSweeper = value!)),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(child: TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text('Cancel'))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF3949AB), Color(0xFF5C6BC0)]), borderRadius: BorderRadius.circular(14)),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                              onPressed: () async {
                                // Close the dialog immediately for a snappy feel
                                Navigator.pop(context);
                                
                                // Show loading spinner in the main UI
                                setState(() => _isLoading = true);
                                
                                try {
                                  // 1. Send it to MongoDB!
                                  await ApiService.createDuty(selectedRoom, 'CSE', selectedSweeper);
                                  
                                  // 2. Fetch the updated list so it includes the real MongoDB ID
                                  await _fetchDuties();
                                } catch (e) {
                                  debugPrint("Creation failed: $e");
                                  setState(() => _isLoading = false);
                                }
                              },
                              child: const Text('Assign', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
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

// ... Keep your existing @override Widget build(BuildContext context) ...

  @override
  Widget build(BuildContext context) {
    int pendingCount = _allDuties.where((d) => d.status == DutyStatus.pending).length;
    int completedCount = _allDuties.where((d) => d.status == DutyStatus.completed).length;
    int verifiedCount = _allDuties.where((d) => d.status == DutyStatus.verified).length;

    // NEW: Logic to filter the duties list based on selected chip
    List<Duty> filteredDuties = _allDuties.where((duty) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Pending' && duty.status == DutyStatus.pending) return true;
      if (_selectedFilter == 'Check' && duty.status == DutyStatus.completed) return true;
      if (_selectedFilter == 'Verified' && duty.status == DutyStatus.verified) return true;
      return false;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F4F8), elevation: 0, surfaceTintColor: Colors.transparent,
        title: const Text('Admin Overview', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87, fontSize: 20)),
        actions: [IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.black54), onPressed: _logout), const SizedBox(width: 4)],
      ),
      body: Column(
        children: [
          // STAT CARDS
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(child: _StatCard(title: 'Pending', count: pendingCount, icon: Icons.pending_actions_rounded, gradient: const [Color(0xFFFFA726), Color(0xFFFB8C00)])),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(title: 'Awaiting Check', count: completedCount, icon: Icons.hourglass_top_rounded, gradient: const [Color(0xFF42A5F5), Color(0xFF1E88E5)])),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(title: 'Verified', count: verifiedCount, icon: Icons.verified_rounded, gradient: const [Color(0xFF66BB6A), Color(0xFF2E7D32)])),
              ],
            ),
          ),
          
          // FACULTY & REPORT BUTTONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: InkWell(
              onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => const InchargeAllotmentScreen()));
              // This runs the moment you hit the 'back' arrow from the Faculty screen!
              _fetchDuties(); 
            },
              borderRadius: BorderRadius.circular(18),
              child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF3949AB).withValues(alpha: 0.15)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]), child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF3949AB).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.manage_accounts_rounded, color: Color(0xFF3949AB))), const SizedBox(width: 16), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Manage Faculty Incharge', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)), Text('Allot professors to verify rooms', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500))])), const Icon(Icons.chevron_right_rounded, color: Colors.grey)])),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: InkWell(
              onTap: () => _showReportSelector(context),
              borderRadius: BorderRadius.circular(18),
              child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFD32F2F).withValues(alpha: 0.2)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]), child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFD32F2F).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFD32F2F))), const SizedBox(width: 16), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Generate PDF Reports', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)), Text('Download classroom & sweeper logs', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500))])), const Icon(Icons.file_download_rounded, color: Colors.grey)])),
            ),
          ),
          
          // PRESET CONTROLS
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Row(
              children: [
                Text('ALL DUTIES', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 1)),
                const Spacer(),
                TextButton.icon(onPressed: _loadPreset, icon: const Icon(Icons.restore_rounded, size: 16), label: const Text('Load Preset', style: TextStyle(fontWeight: FontWeight.bold)), style: TextButton.styleFrom(foregroundColor: const Color(0xFF3949AB), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap)),
                const SizedBox(width: 12),
                TextButton.icon(onPressed: _savePreset, icon: const Icon(Icons.save_rounded, size: 16), label: const Text('Save Preset', style: TextStyle(fontWeight: FontWeight.bold)), style: TextButton.styleFrom(foregroundColor: const Color(0xFF2E7D32), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap)),
              ],
            ),
          ),

          // --- NEW: FILTER CHIPS ---
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Pending'),
                _buildFilterChip('Check'),
                _buildFilterChip('Verified'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // DUTIES LIST (Now uses filteredDuties)
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF3949AB)))
                : filteredDuties.isEmpty
                    ? const Center(child: Text('No duties found in this category.'))
                    : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: filteredDuties.length, // Updated
                    itemBuilder: (context, index) {
                      final duty = filteredDuties[index]; // Updated
                      final color = _getStatusColor(duty.status);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))]),
                        child: Row(
                          children: [
                            Container(width: 46, height: 46, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)), child: Icon(Icons.cleaning_services_rounded, color: color, size: 22)),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(duty.roomName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)), const SizedBox(height: 2),
                            Text(
                              'Sweeper: ${duty.sweeperName ?? "Unassigned"}  •  ${duty.facultyName ?? "Unassigned"}', 
                              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, fontWeight: FontWeight.w700)
                            )])),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)), child: Text(duty.status.name.toUpperCase(), style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w800))),
                            const SizedBox(width: 4),
                            IconButton(icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade300, size: 22), onPressed: () => _deleteDuty(duty.id), tooltip: 'Remove Duty', padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _GradientFab(onPressed: _showAssignDutyDialog),
    );
  }

  // Helper widget to build the modern Filter Chips
  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey.shade700)),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF3949AB),
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300)),
      ),
    );
  }
}

// ... _StatCard and _GradientFab classes remain unchanged at the bottom ...
class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final List<Color> gradient;
  const _StatCard({required this.title, required this.count, required this.icon, required this.gradient});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradient), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: gradient.last.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 22),
          const SizedBox(height: 12),
          Text(count.toString(), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _GradientFab extends StatelessWidget {
  final VoidCallback onPressed;
  const _GradientFab({required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: const LinearGradient(colors: [Color(0xFF3949AB), Color(0xFF5C6BC0)]), boxShadow: [BoxShadow(color: const Color(0xFF3949AB).withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 6))]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add_rounded, color: Colors.white), SizedBox(width: 8), Text('Assign Duty', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))]),
          ),
        ),
      ),
    );
  }
}