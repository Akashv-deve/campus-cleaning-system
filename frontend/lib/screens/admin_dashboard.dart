import 'package:flutter/material.dart';
import '../models/duty_model.dart';
import '../services/api_service.dart';

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
    // Set defaults based on existing data
    String selectedSweeper = ['kumar', 'rajesh', 'lakshmi', 'meena'].contains(duty.sweeperName?.toLowerCase()) 
        ? duty.sweeperName!.toLowerCase() 
        : 'kumar';
        
    String currentFac = duty.facultyName?.replaceAll('Incharge: ', '') ?? 'Prof. Suresh';
    String selectedFaculty = ['Prof. Suresh', 'Prof. Anita', 'Prof. Karthik', 'Prof. Meena'].contains(currentFac) 
        ? currentFac 
        : 'Prof. Suresh';
    
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
                    const Text('Edit Assignment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    
                    // SWEEPER DROPDOWN
                    DropdownButtonFormField<String>(
                      initialValue: selectedSweeper,
                      decoration: InputDecoration(labelText: 'Reassign Sweeper', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
                      items: const ['kumar', 'rajesh', 'lakshmi', 'meena'].map((item) => DropdownMenuItem(value: item, child: Text(item.toUpperCase()))).toList(),
                      onChanged: (value) => setDialogState(() => selectedSweeper = value!),
                    ),
                    const SizedBox(height: 16),
                    
                    // FACULTY DROPDOWN
                    DropdownButtonFormField<String>(
                      initialValue: selectedFaculty,
                      decoration: InputDecoration(labelText: 'Reassign Faculty', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
                      items: const ['Prof. Suresh', 'Prof. Anita', 'Prof. Karthik', 'Prof. Meena'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                      onChanged: (value) => setDialogState(() => selectedFaculty = value!),
                    ),
                    const SizedBox(height: 28),
                    
                    Row(
                      children: [
                        Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3949AB), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                            onPressed: () async {
                              Navigator.pop(context);
                              setState(() => _isLoading = true);
                              try {
                                // Send both names to the new Java route!
                                await ApiService.updateAssignment(duty.id, selectedSweeper, 'Incharge: $selectedFaculty');
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [Icon(Icons.add_task_rounded, color: Color(0xFF3949AB), size: 28), SizedBox(width: 12), Text('Assign New Duty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
                    const SizedBox(height: 24),
                    
                    // SMART ROOM SELECTOR
                    DropdownButtonFormField<String>(
                      initialValue: isCustomRoom ? 'Add New Room...' : selectedRoom,
                      decoration: InputDecoration(labelText: 'Select Room', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
                      items: const ['CSE Lab 1', 'CSE Lab 2', 'IoT Lab', 'Classroom 301', 'HOD Cabin', 'Add New Room...'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          if (value == 'Add New Room...') {
                            isCustomRoom = true;
                          } else {
                            isCustomRoom = false;
                            selectedRoom = value!;
                          }
                        });
                      },
                    ),
                    if (isCustomRoom) ...[
                      const SizedBox(height: 12),
                      TextField(controller: customRoomController, decoration: InputDecoration(hintText: 'Type custom room name...', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
                    ],

                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(initialValue: selectedSweeper, decoration: InputDecoration(labelText: 'Assign Sweeper', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)), items: const ['kumar', 'rajesh', 'lakshmi', 'meena'].map((item) => DropdownMenuItem(value: item, child: Text(item.toUpperCase()))).toList(), onChanged: (value) => setDialogState(() => selectedSweeper = value!)),
                    
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(initialValue: selectedFaculty, decoration: InputDecoration(labelText: 'Assign Faculty', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)), items: const ['Prof. Suresh', 'Prof. Anita', 'Prof. Karthik', 'Prof. Meena'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (value) => setDialogState(() => selectedFaculty = value!)),

                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3949AB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                            onPressed: () async {
                              String finalRoom = isCustomRoom ? customRoomController.text.trim() : selectedRoom;
                              if (finalRoom.isEmpty) return;
                              
                              Navigator.pop(context);
                              setState(() => _isLoading = true);
                              try {
                                // Submits everything in one clean request!
                                await ApiService.createDuty(finalRoom, 'CSE', selectedSweeper, 'Incharge: $selectedFaculty');
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
            );
          },
        );
      },
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
                            
                            // NEW EDIT BUTTON
                            IconButton(
                              icon: Icon(Icons.edit_rounded, color: Colors.blue.shade400, size: 22), 
                              onPressed: () => _showEditAssignmentDialog(duty), // <--- Change this name!
                              tooltip: 'Edit Assignment', 
                              padding: EdgeInsets.zero, 
                              constraints: const BoxConstraints(minWidth: 36)
                            ),
                            // DELETE BUTTON
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