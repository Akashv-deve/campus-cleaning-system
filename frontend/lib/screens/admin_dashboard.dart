import 'package:flutter/material.dart';
import '../models/duty_model.dart';
import '../services/api_service.dart';
import 'log_report_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _selectedFilter = 'All';
  List<Duty> _allDuties = []; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDuties();
  }

  Future<void> _fetchDuties() async {
    try {
      final fetchedDuties = await ApiService.getAllDuties();
      setState(() {
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

  Future<void> _deleteDuty(String dutyId) async {
    try {
      await ApiService.deleteDuty(dutyId);
      setState(() => _allDuties.removeWhere((duty) => duty.id == dutyId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Row(children: [Icon(Icons.delete_outline_rounded, color: Colors.white), SizedBox(width: 10), Text('Duty permanently deleted.')]), backgroundColor: const Color(0xFFC62828), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), duration: const Duration(seconds: 2)));
    } catch (e) {
      debugPrint("Delete failed: $e");
    }
  }

  // --- UPGRADED: EDIT BOTH ASSIGNMENTS DIALOG ---
  void _showEditAssignmentDialog(Duty duty) {
    // Dynamically build lists so custom names from DB don't crash the dropdown
    String currentSweeper = duty.sweeperName?.toLowerCase() ?? 'kumar';
    List<String> sweeperOptions = ['kumar', 'rajesh', 'lakshmi', 'meena'];
    if (!sweeperOptions.contains(currentSweeper) && currentSweeper != 'unassigned') sweeperOptions.insert(0, currentSweeper);
    sweeperOptions.add('Add New Sweeper...');

    String currentFac = duty.facultyName?.replaceAll('Incharge: ', '') ?? 'Prof. Suresh';
    List<String> facultyOptions = ['Prof. Suresh', 'Prof. Anita', 'Prof. Karthik', 'Prof. Meena'];
    if (!facultyOptions.contains(currentFac) && currentFac != 'Unassigned') facultyOptions.insert(0, currentFac);
    facultyOptions.add('Add New Faculty...');

    bool isCustomSweeper = false;
    final customSweeperController = TextEditingController();
    bool isCustomFaculty = false;
    final customFacultyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              child: Padding(
                padding: const EdgeInsets.all(26.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Edit Assignment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      
                      // SWEEPER DROPDOWN
                      DropdownButtonFormField<String>(
                        initialValue: currentSweeper,
                        decoration: InputDecoration(labelText: 'Reassign Sweeper', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
                        items: sweeperOptions.map((item) => DropdownMenuItem(value: item, child: Text(item.toUpperCase()))).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            if (value == 'Add New Sweeper...') { isCustomSweeper = true; } 
                            else { isCustomSweeper = false; currentSweeper = value!; }
                          });
                        },
                      ),
                      if (isCustomSweeper) ...[
                        const SizedBox(height: 12),
                        TextField(controller: customSweeperController, decoration: InputDecoration(hintText: 'Type new sweeper name...', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
                      ],
                      
                      const SizedBox(height: 16),
                      // FACULTY DROPDOWN
                      DropdownButtonFormField<String>(
                        initialValue: currentFac,
                        decoration: InputDecoration(labelText: 'Reassign Faculty', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
                        items: facultyOptions.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            if (value == 'Add New Faculty...') { isCustomFaculty = true; } 
                            else { isCustomFaculty = false; currentFac = value!; }
                          });
                        },
                      ),
                      if (isCustomFaculty) ...[
                        const SizedBox(height: 12),
                        TextField(controller: customFacultyController, decoration: InputDecoration(hintText: 'e.g., Prof. Rajesh', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
                      ],

                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3949AB), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                              onPressed: () async {
                                String finalSweeper = isCustomSweeper ? customSweeperController.text.trim().toLowerCase() : currentSweeper;
                                String finalFac = isCustomFaculty ? 'Incharge: ${customFacultyController.text.trim()}' : 'Incharge: $currentFac';
                                if (finalSweeper.isEmpty || (isCustomFaculty && customFacultyController.text.trim().isEmpty)) return;
                                
                                Navigator.pop(context);
                                setState(() => _isLoading = true);
                                try {
                                  await ApiService.updateAssignment(duty.id, finalSweeper, finalFac);
                                  await _fetchDuties();
                                } catch (e) {
                                  debugPrint("Update failed: $e");
                                  setState(() => _isLoading = false);
                                }
                              },
                              child: const Text('Update'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- UPGRADED: ASSIGN DUTY DIALOG ---
  void _showAssignDutyDialog() {
    String selectedRoom = 'CSE Lab 1';
    bool isCustomRoom = false;
    final customRoomController = TextEditingController();
    
    String selectedSweeper = 'kumar';
    bool isCustomSweeper = false;
    final customSweeperController = TextEditingController();
    
    String selectedFaculty = 'Prof. Suresh';
    bool isCustomFaculty = false;
    final customFacultyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              child: Padding(
                padding: const EdgeInsets.all(26.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [Icon(Icons.add_task_rounded, color: Color(0xFF3949AB), size: 28), SizedBox(width: 12), Text('Assign New Duty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
                      const SizedBox(height: 24),
                      
                      // ROOM
                      DropdownButtonFormField<String>(
                        initialValue: selectedRoom,
                        decoration: InputDecoration(labelText: 'Select Room', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
                        items: const ['CSE Lab 1', 'CSE Lab 2', 'IoT Lab', 'Classroom 301', 'HOD Cabin', 'Add New Room...'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            if (value == 'Add New Room...') { isCustomRoom = true; } 
                            else { isCustomRoom = false; selectedRoom = value!; }
                          });
                        },
                      ),
                      if (isCustomRoom) ...[
                        const SizedBox(height: 12),
                        TextField(controller: customRoomController, decoration: InputDecoration(hintText: 'Type custom room name...', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
                      ],

                      const SizedBox(height: 16),
                      // SWEEPER
                      DropdownButtonFormField<String>(
                        initialValue: selectedSweeper, 
                        decoration: InputDecoration(labelText: 'Assign Sweeper', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)), 
                        items: const ['kumar', 'rajesh', 'lakshmi', 'meena', 'Add New Sweeper...'].map((item) => DropdownMenuItem(value: item, child: Text(item.toUpperCase()))).toList(), 
                        onChanged: (value) {
                          setDialogState(() {
                            if (value == 'Add New Sweeper...') { isCustomSweeper = true; } 
                            else { isCustomSweeper = false; selectedSweeper = value!; }
                          });
                        },
                      ),
                      if (isCustomSweeper) ...[
                        const SizedBox(height: 12),
                        TextField(controller: customSweeperController, decoration: InputDecoration(hintText: 'Type new sweeper name...', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
                      ],
                      
                      const SizedBox(height: 16),
                      // FACULTY
                      DropdownButtonFormField<String>(
                        initialValue: selectedFaculty, 
                        decoration: InputDecoration(labelText: 'Assign Faculty', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)), 
                        items: const ['Prof. Suresh', 'Prof. Anita', 'Prof. Karthik', 'Prof. Meena', 'Add New Faculty...'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), 
                        onChanged: (value) {
                          setDialogState(() {
                            if (value == 'Add New Faculty...') { isCustomFaculty = true; } 
                            else { isCustomFaculty = false; selectedFaculty = value!; }
                          });
                        }
                      ),
                      if (isCustomFaculty) ...[
                        const SizedBox(height: 12),
                        TextField(controller: customFacultyController, decoration: InputDecoration(hintText: 'e.g., Prof. Rajesh', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
                      ],

                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3949AB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                              onPressed: () async {
                                String finalRoom = isCustomRoom ? customRoomController.text.trim() : selectedRoom;
                                String finalSweeper = isCustomSweeper ? customSweeperController.text.trim().toLowerCase() : selectedSweeper;
                                String finalFac = isCustomFaculty ? 'Incharge: ${customFacultyController.text.trim()}' : 'Incharge: $selectedFaculty';
                                
                                if (finalRoom.isEmpty || finalSweeper.isEmpty || (isCustomFaculty && customFacultyController.text.trim().isEmpty)) return;
                                
                                Navigator.pop(context);
                                setState(() => _isLoading = true);
                                try {
                                  await ApiService.createDuty(finalRoom, 'CSE', finalSweeper, finalFac);
                                  await _fetchDuties();
                                } catch (e) {
                                  debugPrint("Creation failed: $e");
                                  setState(() => _isLoading = false);
                                }
                              },
                              child: const Text('Assign', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  // --- PDF REPORT FUNCTIONS ---
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
              _buildReportOption(context, title: 'Sweeper Log Report', subtitle: 'Daily attendance & completion stats', icon: Icons.person_search_rounded, color: const Color(0xFF00897B), type: 'sweeper'),
              const SizedBox(height: 12),
              _buildReportOption(context, title: 'Classroom Status Log', subtitle: 'Verification history by faculty', icon: Icons.meeting_room_rounded, color: const Color(0xFFE53935), type: 'classroom'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportOption(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required String type}) {
    return InkWell(
      onTap: () { 
        Navigator.pop(context); 
        Navigator.push(context, MaterialPageRoute(builder: (context) => LogReportScreen(
          duties: _allDuties, 
          reportTitle: title, 
          reportType: type,
        ))); 
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5), borderRadius: BorderRadius.circular(16), color: color.withValues(alpha: 0.05)),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 26)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)), const SizedBox(height: 2), Text(subtitle, style: TextStyle(color: Colors.grey.shade700, fontSize: 13))])),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int pendingCount = _allDuties.where((d) => d.status == DutyStatus.pending).length;
    int completedCount = _allDuties.where((d) => d.status == DutyStatus.completed).length;
    int verifiedCount = _allDuties.where((d) => d.status == DutyStatus.verified).length;

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
        actions: [IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.black54), onPressed: _logout)],
      ),
      body: Column(
        children: [
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
          
          // PDF BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: InkWell(
              onTap: () => _showReportSelector(context),
              borderRadius: BorderRadius.circular(18),
              child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFD32F2F).withValues(alpha: 0.2)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]), child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFD32F2F).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFD32F2F))), const SizedBox(width: 16), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Generate PDF Reports', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)), Text('Download classroom & sweeper logs', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500))])), const Icon(Icons.file_download_rounded, color: Colors.grey)])),
            ),
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('All'), _buildFilterChip('Pending'), _buildFilterChip('Check'), _buildFilterChip('Verified'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF3949AB)))
                : filteredDuties.isEmpty
                    ? const Center(child: Text('No duties found.'))
                    : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: filteredDuties.length, 
                    itemBuilder: (context, index) {
                      final duty = filteredDuties[index]; 
                      final color = _getStatusColor(duty.status);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))]),
                        child: Row(
                          children: [
                            Container(width: 46, height: 46, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)), child: Icon(Icons.cleaning_services_rounded, color: color, size: 22)),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(duty.roomName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)), 
                              const SizedBox(height: 2), 
                              Text('Sweeper: ${duty.sweeperName?.toUpperCase() ?? "Unassigned"} • ${duty.facultyName ?? "Unassigned"}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600))
                            ])),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)), child: Text(duty.status.name.toUpperCase(), style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w800))),
                            
                            IconButton(icon: Icon(Icons.edit_rounded, color: Colors.blue.shade400, size: 22), onPressed: () => _showEditAssignmentDialog(duty), tooltip: 'Edit Assignment', padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 36)),
                            IconButton(icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade300, size: 22), onPressed: () => _deleteDuty(duty.id), tooltip: 'Remove Duty', padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 36)),
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

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey.shade700)),
        selected: isSelected,
        onSelected: (bool selected) => setState(() => _selectedFilter = label),
        backgroundColor: Colors.white, selectedColor: const Color(0xFF3949AB), checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300)),
      ),
    );
  }
}

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