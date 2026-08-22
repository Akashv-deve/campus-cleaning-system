import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/duty_model.dart';
import '../services/api_service.dart';
import 'log_report_screen.dart';
import 'package:shimmer/shimmer.dart';

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

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userRole');
    await prefs.remove('userName');
    
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/'); // Or Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
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

  void _showPresetsMenu(BuildContext context) {
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
              const Row(children: [Icon(Icons.bookmark_added_rounded, color: Color(0xFF8E24AA), size: 28), SizedBox(width: 12), Text('Duty Presets', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87))]),
              const SizedBox(height: 24),
              _buildMenuOption(context, title: 'Save Current as Preset', subtitle: 'Save live board to a template', icon: Icons.save_rounded, color: const Color(0xFF8E24AA), onTap: () { Navigator.pop(context); _showSavePresetDialog(); }),
              const SizedBox(height: 12),
              _buildMenuOption(context, title: 'Use Saved Preset', subtitle: 'Load and assign a saved template', icon: Icons.dynamic_feed_rounded, color: const Color(0xFF00897B), onTap: () { Navigator.pop(context); _showLoadPresetDialog(); }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuOption(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
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

  void _showSavePresetDialog() {
    // Strips out legacy prefixes safely for the UI
    List<Map<String, String>> draftDuties = _allDuties.map((d) => {
      'roomName': d.roomName,
      'sweeperName': d.sweeperName ?? 'unassigned',
      'facultyName': d.facultyName?.replaceAll('Incharge: ', '').replaceAll('Prof. ', '') ?? 'Unassigned',
    }).toList();
    
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Save Duty Preset', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(controller: nameController, decoration: InputDecoration(labelText: 'Preset Name', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
                    const SizedBox(height: 16),
                    const Align(alignment: Alignment.centerLeft, child: Text('Assignments in Preset:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                    const SizedBox(height: 8),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                      child: ListView.builder(
                        itemCount: draftDuties.length,
                        itemBuilder: (context, index) {
                          final d = draftDuties[index];
                          return ListTile(
                            dense: true,
                            title: Text(d['roomName']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${d['sweeperName']?.toUpperCase()} • ${d['facultyName']?.toUpperCase()}'), // Capitalized matching
                            trailing: IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => setDialogState(() => draftDuties.removeAt(index))),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () async {
                        final newDuty = await _showDraftDutyAddDialog();
                        if (newDuty != null) setDialogState(() => draftDuties.add(newDuty));
                      },
                      icon: const Icon(Icons.add_rounded), label: const Text('Add Room to Preset'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8E24AA), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                            onPressed: () async {
                              if (nameController.text.trim().isEmpty || draftDuties.isEmpty) return;
                              Navigator.pop(context);
                              final prefs = await SharedPreferences.getInstance();
                              final String? presetsJson = prefs.getString('saved_presets');
                              List<dynamic> presets = presetsJson != null ? jsonDecode(presetsJson) : [];
                              presets.add({'presetName': nameController.text.trim(), 'duties': draftDuties});
                              await prefs.setString('saved_presets', jsonEncode(presets));
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preset saved successfully!'), backgroundColor: Color(0xFF2E7D32)));
                            },
                            child: const Text('Save Preset'),
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

  Future<Map<String, String>?> _showDraftDutyAddDialog() async {
    List<String> roomOptions = _allDuties.map((d) => d.roomName).toSet().toList();
    if (roomOptions.isEmpty) { 
      roomOptions = ['Add New Room...']; 
    } else { 
      roomOptions.add('Add New Room...'); 
    }
    
    List<String> sweeperOptions = _allDuties.map((d) => d.sweeperName?.toLowerCase() ?? '').where((s) => s.isNotEmpty && s != 'unassigned').toSet().toList();
    if (sweeperOptions.isEmpty) { 
      sweeperOptions = ['Add New Sweeper...']; 
    } else { 
      sweeperOptions.add('Add New Sweeper...'); 
    }
    
    List<String> inchargeOptions = _allDuties.map((d) => d.facultyName?.replaceAll('Incharge: ', '').replaceAll('Prof. ', '') ?? '').where((f) => f.isNotEmpty && f != 'Unassigned').toSet().toList();
    if (inchargeOptions.isEmpty) { 
      inchargeOptions = ['Add New Incharge...']; 
    } else { 
      inchargeOptions.add('Add New Incharge...'); 
    }

    String selectedRoom = roomOptions.first;
    bool isCustomRoom = selectedRoom == 'Add New Room...';
    final customRoomController = TextEditingController();
    String selectedSweeper = sweeperOptions.first;
    bool isCustomSweeper = selectedSweeper == 'Add New Sweeper...';
    final customSweeperController = TextEditingController();
    String selectedIncharge = inchargeOptions.first;
    bool isCustomIncharge = selectedIncharge == 'Add New Incharge...';
    final customInchargeController = TextEditingController();

    return showDialog<Map<String, String>>(
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
                      const Text('Add to Preset', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<String>(initialValue: selectedRoom, decoration: InputDecoration(labelText: 'Room', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)), items: roomOptions.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (v) => setDialogState(() { isCustomRoom = v == 'Add New Room...'; selectedRoom = v!; })),
                      if (isCustomRoom) Padding(padding: const EdgeInsets.only(top: 12), child: TextField(controller: customRoomController, decoration: InputDecoration(hintText: 'Custom room name...', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)))),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(initialValue: selectedSweeper, decoration: InputDecoration(labelText: 'Sweeper', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)), items: sweeperOptions.map((item) => DropdownMenuItem(value: item, child: Text(item.toUpperCase()))).toList(), onChanged: (v) => setDialogState(() { isCustomSweeper = v == 'Add New Sweeper...'; selectedSweeper = v!; })),
                      if (isCustomSweeper) Padding(padding: const EdgeInsets.only(top: 12), child: TextField(controller: customSweeperController, decoration: InputDecoration(hintText: 'New sweeper name...', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)))),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(initialValue: selectedIncharge, decoration: InputDecoration(labelText: 'Incharge', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)), items: inchargeOptions.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (v) => setDialogState(() { isCustomIncharge = v == 'Add New Incharge...'; selectedIncharge = v!; })),
                      if (isCustomIncharge) Padding(padding: const EdgeInsets.only(top: 12), child: TextField(controller: customInchargeController, decoration: InputDecoration(hintText: 'Incharge name...', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)))),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3949AB), foregroundColor: Colors.white),
                              onPressed: () {
                                String r = isCustomRoom ? customRoomController.text.trim() : selectedRoom;
                                String s = isCustomSweeper ? customSweeperController.text.trim().toLowerCase() : selectedSweeper;
                                String i = isCustomIncharge ? customInchargeController.text.trim() : selectedIncharge;
                                if (r.isEmpty || s.isEmpty || i.isEmpty) return;
                                Navigator.pop(context, {'roomName': r, 'sweeperName': s, 'facultyName': i}); // Passes raw name
                              },
                              child: const Text('Add'),
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

  void _showLoadPresetDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final String? presetsJson = prefs.getString('saved_presets');
    List<dynamic> presets = presetsJson != null ? jsonDecode(presetsJson) : [];

    if (!mounted) return;
    if (presets.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No presets saved yet!'), backgroundColor: Color(0xFFEF6C00))); return; }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Load Preset', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: presets.length,
                    itemBuilder: (context, index) {
                      final preset = presets[index];
                      return Card(
                        elevation: 0,
                        color: const Color(0xFFF3F4F8),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(preset['presetName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${(preset['duties'] as List).length} assignments saved'),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          onTap: () { Navigator.pop(context); _showPresetDetailsDialog(preset); },
                        ),
                      );
                    },
                  ),
                ),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPresetDetailsDialog(Map<String, dynamic> preset) {
    List<dynamic> duties = preset['duties'];
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(preset['presetName'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Are you sure you want to deploy these assignments to the live board?'),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                  child: ListView.builder(
                    itemCount: duties.length,
                    itemBuilder: (context, index) {
                      final d = duties[index];
                      return ListTile(
                        dense: true,
                        title: Text(d['roomName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${d['sweeperName'].toUpperCase()} • ${d['facultyName'].toUpperCase()}'), // Capitalized matching
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        onPressed: () async {
                          Navigator.pop(context);
                          setState(() => _isLoading = true);
                          try {
                            await Future.wait(duties.map((d) => ApiService.createDuty(d['roomName'], 'CSE', d['sweeperName'], d['facultyName'])));
                            await _fetchDuties();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preset deployed successfully!'), backgroundColor: Color(0xFF2E7D32)));
                          } catch (e) {
                            setState(() => _isLoading = false);
                            debugPrint("Deploy failed: $e");
                            
                            // NEW: Show the error message to the Admin!
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString().replaceAll('Exception: ', '')),
                                backgroundColor: const Color(0xFFC62828), 
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          }
                        },
                        child: const Text('Deploy Preset'),
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
  }

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
              _buildMenuOption(context, title: 'Sweeper Log Report', subtitle: 'Daily attendance & completion stats', icon: Icons.person_search_rounded, color: const Color(0xFF00897B), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => LogReportScreen(duties: _allDuties, reportTitle: 'Sweeper Log', reportType: 'sweeper'))); }),
              const SizedBox(height: 12),
              _buildMenuOption(context, title: 'Classroom Status Log', subtitle: 'Verification history', icon: Icons.meeting_room_rounded, color: const Color(0xFFE53935), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => LogReportScreen(duties: _allDuties, reportTitle: 'Classroom Log', reportType: 'classroom'))); }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _bulkDeleteLogs() async {
    final selectedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2023), lastDate: DateTime.now(), helpText: 'SELECT CUT-OFF DATE', confirmText: 'PURGE OLD LOGS');
    if (selectedDate == null) return; 

    setState(() => _isLoading = true);
    int deletedCount = 0;

    for (var duty in _allDuties) {
      if (duty.status == DutyStatus.verified && duty.verifiedTime != null) {
        try {
          final parts = duty.verifiedTime!.split(', ');
          final dateParts = parts[0].split('/');
          final dutyDate = DateTime(DateTime.now().year, int.parse(dateParts[1]), int.parse(dateParts[0]));
          if (dutyDate.isBefore(selectedDate) || dutyDate.isAtSameMomentAs(selectedDate)) { await ApiService.deleteDuty(duty.id); deletedCount++; }
        } catch (e) { debugPrint("Date parse skipped: $e"); }
      }
    }
    await _fetchDuties(); 
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(deletedCount > 0 ? 'Successfully purged $deletedCount old records.' : 'No verified logs found before that date.'), backgroundColor: deletedCount > 0 ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00), behavior: SnackBarBehavior.floating));
  }

  void _showEditAssignmentDialog(Duty duty) {
    List<String> sweeperOptions = _allDuties.map((d) => d.sweeperName?.toLowerCase() ?? '').where((s) => s.isNotEmpty && s != 'unassigned').toSet().toList();
    if (sweeperOptions.isEmpty) { sweeperOptions = ['Add New Sweeper...']; } else { sweeperOptions.add('Add New Sweeper...'); }
    List<String> inchargeOptions = _allDuties.map((d) => d.facultyName?.replaceAll('Incharge: ', '').replaceAll('Prof. ', '') ?? '').where((f) => f.isNotEmpty && f != 'Unassigned').toSet().toList();
    if (inchargeOptions.isEmpty) { inchargeOptions = ['Add New Incharge...']; } else { inchargeOptions.add('Add New Incharge...'); }

    String currentSweeper = duty.sweeperName?.toLowerCase() ?? '';
    if (!sweeperOptions.contains(currentSweeper) && currentSweeper.isNotEmpty) { sweeperOptions.insert(0, currentSweeper); }
    if (currentSweeper.isEmpty || currentSweeper == 'unassigned') { currentSweeper = sweeperOptions.first; }

    String currentInc = duty.facultyName?.replaceAll('Incharge: ', '').replaceAll('Prof. ', '') ?? '';
    if (!inchargeOptions.contains(currentInc) && currentInc.isNotEmpty) { inchargeOptions.insert(0, currentInc); }
    if (currentInc.isEmpty || currentInc == 'Unassigned') { currentInc = inchargeOptions.first; }

    bool isCustomSweeper = currentSweeper == 'Add New Sweeper...';
    final customSweeperController = TextEditingController();
    bool isCustomIncharge = currentInc == 'Add New Incharge...';
    final customInchargeController = TextEditingController();
    
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
                      DropdownButtonFormField<String>(initialValue: currentSweeper, decoration: InputDecoration(labelText: 'Reassign Sweeper', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)), items: sweeperOptions.map((item) => DropdownMenuItem(value: item, child: Text(item.toUpperCase()))).toList(), onChanged: (value) { setDialogState(() { if (value == 'Add New Sweeper...') { isCustomSweeper = true; } else { isCustomSweeper = false; currentSweeper = value!; } }); }),
                      if (isCustomSweeper) Padding(padding: const EdgeInsets.only(top: 12), child: TextField(controller: customSweeperController, decoration: InputDecoration(hintText: 'Type new sweeper name...', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)))),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(initialValue: currentInc, decoration: InputDecoration(labelText: 'Reassign Incharge', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)), items: inchargeOptions.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (value) { setDialogState(() { if (value == 'Add New Incharge...') { isCustomIncharge = true; } else { isCustomIncharge = false; currentInc = value!; } }); }),
                      if (isCustomIncharge) Padding(padding: const EdgeInsets.only(top: 12), child: TextField(controller: customInchargeController, decoration: InputDecoration(hintText: 'Type incharge name...', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)))),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3949AB), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                              onPressed: () async {
                                String finalSweeper = isCustomSweeper ? customSweeperController.text.trim().toLowerCase() : currentSweeper;
                                String finalInc = isCustomIncharge ? customInchargeController.text.trim() : currentInc; // Raw Name Used!
                                if (finalSweeper.isEmpty || (isCustomIncharge && customInchargeController.text.trim().isEmpty)) return;
                                Navigator.pop(context);
                                setState(() => _isLoading = true);
                                try { await ApiService.updateAssignment(duty.id, finalSweeper, finalInc); await _fetchDuties(); } catch (e) { debugPrint("Update failed: $e"); setState(() => _isLoading = false); }
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

  void _showAssignDutyDialog() {
    List<String> roomOptions = _allDuties.map((d) => d.roomName).toSet().toList();
    if (roomOptions.isEmpty) { roomOptions = ['Add New Room...']; } else { roomOptions.add('Add New Room...'); }
    List<String> sweeperOptions = _allDuties.map((d) => d.sweeperName?.toLowerCase() ?? '').where((s) => s.isNotEmpty && s != 'unassigned').toSet().toList();
    if (sweeperOptions.isEmpty) { sweeperOptions = ['Add New Sweeper...']; } else { sweeperOptions.add('Add New Sweeper...'); }
    List<String> inchargeOptions = _allDuties.map((d) => d.facultyName?.replaceAll('Incharge: ', '').replaceAll('Prof. ', '') ?? '').where((f) => f.isNotEmpty && f != 'Unassigned').toSet().toList();
    if (inchargeOptions.isEmpty) { inchargeOptions = ['Add New Incharge...']; } else { inchargeOptions.add('Add New Incharge...'); }

    String selectedRoom = roomOptions.first;
    bool isCustomRoom = selectedRoom == 'Add New Room...';
    final customRoomController = TextEditingController();
    
    String selectedSweeper = sweeperOptions.first;
    bool isCustomSweeper = selectedSweeper == 'Add New Sweeper...';
    final customSweeperController = TextEditingController();
    
    String selectedIncharge = inchargeOptions.first;
    bool isCustomIncharge = selectedIncharge == 'Add New Incharge...';
    final customInchargeController = TextEditingController();

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
                      DropdownButtonFormField<String>(initialValue: selectedRoom, decoration: InputDecoration(labelText: 'Select Room', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)), items: roomOptions.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (v) { setDialogState(() { if (v == 'Add New Room...') { isCustomRoom = true; } else { isCustomRoom = false; selectedRoom = v!; } }); }),
                      if (isCustomRoom) Padding(padding: const EdgeInsets.only(top: 12), child: TextField(controller: customRoomController, decoration: InputDecoration(hintText: 'Type custom room name...', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)))),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(initialValue: selectedSweeper, decoration: InputDecoration(labelText: 'Assign Sweeper', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)), items: sweeperOptions.map((item) => DropdownMenuItem(value: item, child: Text(item.toUpperCase()))).toList(), onChanged: (v) { setDialogState(() { if (v == 'Add New Sweeper...') { isCustomSweeper = true; } else { isCustomSweeper = false; selectedSweeper = v!; } }); }),
                      if (isCustomSweeper) Padding(padding: const EdgeInsets.only(top: 12), child: TextField(controller: customSweeperController, decoration: InputDecoration(hintText: 'Type new sweeper name...', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)))),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(initialValue: selectedIncharge, decoration: InputDecoration(labelText: 'Assign Incharge', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)), items: inchargeOptions.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (v) { setDialogState(() { if (v == 'Add New Incharge...') { isCustomIncharge = true; } else { isCustomIncharge = false; selectedIncharge = v!; } }); }),
                      if (isCustomIncharge) Padding(padding: const EdgeInsets.only(top: 12), child: TextField(controller: customInchargeController, decoration: InputDecoration(hintText: 'Type incharge name...', filled: true, fillColor: const Color(0xFFF7F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)))),
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
                                String finalInc = isCustomIncharge ? customInchargeController.text.trim() : selectedIncharge; // Raw Name Used!
                                
                                if (finalRoom.isEmpty || finalSweeper.isEmpty || (isCustomIncharge && customInchargeController.text.trim().isEmpty)) return;
                                
                                Navigator.pop(context);
                                setState(() => _isLoading = true);
                                try { 
                                await ApiService.createDuty(finalRoom, 'CSE', finalSweeper, finalInc); 
                                await _fetchDuties(); 
                              } catch (e) { 
                                debugPrint("Creation failed: $e"); 
                                setState(() => _isLoading = false); 
                                
                                // NEW: Show the error message to the Admin!
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    // .replaceAll removes the ugly "Exception: " prefix from the text
                                    content: Text(e.toString().replaceAll('Exception: ', '')), 
                                    backgroundColor: const Color(0xFFC62828), // Red color for errors
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
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

  // --- PREMIUM UX: SHIMMER LOADING EFFECT ---
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: 6, // Displays 6 animated skeleton cards
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14))),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 180, height: 16, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                      const SizedBox(height: 8),
                      Container(width: 120, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(width: 60, height: 26, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
              ],
            ),
          ),
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
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(child: _ActionCard(title: 'Reports', icon: Icons.picture_as_pdf_rounded, color: const Color(0xFF1976D2), onTap: () => _showReportSelector(context))),
                const SizedBox(width: 12),
                Expanded(child: _ActionCard(title: 'Presets', icon: Icons.bookmark_added_rounded, color: const Color(0xFF8E24AA), onTap: () => _showPresetsMenu(context))),
                const SizedBox(width: 12),
                Expanded(child: _ActionCard(title: 'Purge', icon: Icons.auto_delete_rounded, color: const Color(0xFFD32F2F), onTap: _bulkDeleteLogs)),
              ],
            ),
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [_buildFilterChip('All'), _buildFilterChip('Pending'), _buildFilterChip('Check'), _buildFilterChip('Verified')],
            ),
          ),
          const SizedBox(height: 12),
          
          Expanded(
            child: _isLoading 
                ? _buildShimmerLoading() // Triggers the animated skeleton!
                : RefreshIndicator(
                    onRefresh: _fetchDuties, // Triggers database fetch on pull down!
                    color: const Color(0xFF3949AB),
                    backgroundColor: Colors.white,
                    child: filteredDuties.isEmpty
                        ? ListView(
                            // Forces scrolling even if empty so users can pull to refresh
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 100),
                              Center(child: Text('No duties found.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                            ],
                          )
                        : ListView.builder(
                            // AlwaysScrollable is required for pull-to-refresh to work consistently
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            itemCount: filteredDuties.length, 
                            itemBuilder: (context, index) {
                              final duty = filteredDuties[index]; 
                              final color = _getStatusColor(duty.status);
                              String cleanIncharge = duty.facultyName?.replaceAll("Incharge: ", "").replaceAll("Prof. ", "") ?? "UNASSIGNED";

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
                                      Text('Sweeper: ${duty.sweeperName?.toUpperCase() ?? "UNASSIGNED"} • ${cleanIncharge.toUpperCase()}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600))
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

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withValues(alpha: 0.2)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 22)),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
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