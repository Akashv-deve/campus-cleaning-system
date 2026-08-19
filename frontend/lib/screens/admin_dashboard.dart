// lib/screens/admin_dashboard.dart
import 'package:flutter/material.dart';
import '../models/duty_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final List<Duty> _allDuties = [
    Duty(id: '1', roomName: 'CSE Lab 1', department: 'Computer Science', status: DutyStatus.verified),
    Duty(id: '2', roomName: 'Classroom 302', department: 'Mechanical', status: DutyStatus.completed),
    Duty(id: '3', roomName: 'Physics Lab', department: 'Science', status: DutyStatus.pending),
    Duty(id: '4', roomName: 'Main Auditorium', department: 'Admin', status: DutyStatus.pending),
  ];

  void _logout() {
    Navigator.pushReplacementNamed(context, '/');
  }

  Color _getStatusColor(DutyStatus status) {
    switch (status) {
      case DutyStatus.pending: return Colors.orange;
      case DutyStatus.completed: return Colors.blue;
      case DutyStatus.verified: return Colors.green;
      case DutyStatus.rejected: return Colors.red;
    }
  }

  // --- SAME DIALOG LOGIC FROM BEFORE ---
  void _showAssignDutyDialog() {
    String selectedRoom = 'ECE Lab';
    String selectedSweeper = 'Sweeper Kumar';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assign New Duty'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedRoom,
                decoration: const InputDecoration(labelText: 'Select Room', border: OutlineInputBorder()),
                items: ['ECE Lab', 'Civil Workshop', 'Library', 'Main Auditorium']
                    .map((room) => DropdownMenuItem(value: room, child: Text(room))).toList(),
                onChanged: (value) => selectedRoom = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedSweeper,
                decoration: const InputDecoration(labelText: 'Assign to Sweeper', border: OutlineInputBorder()),
                items: ['Sweeper Kumar', 'Sweeper Ramesh', 'Sweeper Lakshmi']
                    .map((sweeper) => DropdownMenuItem(value: sweeper, child: Text(sweeper))).toList(),
                onChanged: (value) => selectedSweeper = value!,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _allDuties.insert(0, Duty(id: DateTime.now().toString(), roomName: selectedRoom, department: 'Assigned manually', status: DutyStatus.pending));
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Duty assigned to $selectedSweeper successfully!')));
              },
              child: const Text('Assign'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate stats for the dashboard
    int pendingCount = _allDuties.where((d) => d.status == DutyStatus.pending).length;
    int completedCount = _allDuties.where((d) => d.status == DutyStatus.completed).length;
    int verifiedCount = _allDuties.where((d) => d.status == DutyStatus.verified).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Overview'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          // NEW: Top Summary Dashboard
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              border: Border(bottom: BorderSide(color: Colors.indigo.shade100)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Pending', pendingCount, Colors.orange),
                _buildStatCard('Awaiting Check', completedCount, Colors.blue),
                _buildStatCard('Verified', verifiedCount, Colors.green),
              ],
            ),
          ),
          // EXISTING: List of duties
          Expanded(
            child: _allDuties.isEmpty
                ? const Center(child: Text('No duties assigned yet.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _allDuties.length,
                    itemBuilder: (context, index) {
                      final duty = _allDuties[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(duty.status).withOpacity(0.15),
                            child: Icon(Icons.cleaning_services, color: _getStatusColor(duty.status)),
                          ),
                          title: Text(duty.roomName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            'Status: ${duty.status.name.toUpperCase()}',
                            style: TextStyle(color: _getStatusColor(duty.status), fontWeight: FontWeight.w600),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAssignDutyDialog,
        icon: const Icon(Icons.add),
        label: const Text('Assign Duty'),
      ),
    );
  }

  // Helper widget to build the stat cards
  Widget _buildStatCard(String title, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}