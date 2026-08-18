// lib/screens/admin_dashboard.dart
import 'package:flutter/material.dart';
import '../models/duty_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // MOCK DATA: All duties in the system
  final List<Duty> _allDuties = [
    Duty(id: '1', roomName: 'CSE Lab 1', department: 'Computer Science', status: DutyStatus.verified),
    Duty(id: '2', roomName: 'Classroom 302', department: 'Mechanical', status: DutyStatus.completed),
    Duty(id: '3', roomName: 'Physics Lab', department: 'Science', status: DutyStatus.pending),
  ];

  void _logout() {
    Navigator.pushReplacementNamed(context, '/');
  }

  // Helper function to get color based on status
  Color _getStatusColor(DutyStatus status) {
    switch (status) {
      case DutyStatus.pending: return Colors.orange;
      case DutyStatus.completed: return Colors.blue;
      case DutyStatus.verified: return Colors.green;
      case DutyStatus.rejected: return Colors.red;
    }
  }

  // Dialog to assign a new duty
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
              // MOCK DROPDOWN FOR ROOMS
              DropdownButtonFormField<String>(
                value: selectedRoom,
                decoration: const InputDecoration(labelText: 'Select Room'),
                items: ['ECE Lab', 'Civil Workshop', 'Library', 'Main Auditorium']
                    .map((room) => DropdownMenuItem(value: room, child: Text(room)))
                    .toList(),
                onChanged: (value) => selectedRoom = value!,
              ),
              const SizedBox(height: 16),
              // MOCK DROPDOWN FOR SWEEPERS
              DropdownButtonFormField<String>(
                value: selectedSweeper,
                decoration: const InputDecoration(labelText: 'Assign to Sweeper'),
                items: ['Sweeper Kumar', 'Sweeper Ramesh', 'Sweeper Lakshmi']
                    .map((sweeper) => DropdownMenuItem(value: sweeper, child: Text(sweeper)))
                    .toList(),
                onChanged: (value) => selectedSweeper = value!,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _allDuties.insert(
                    0, // Add to the top of the list
                    Duty(
                      id: DateTime.now().toString(),
                      roomName: selectedRoom,
                      department: 'Assigned manually',
                      status: DutyStatus.pending,
                    ),
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Duty assigned to $selectedSweeper successfully!')),
                );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Overview'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _allDuties.isEmpty
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
                      backgroundColor: _getStatusColor(duty.status).withOpacity(0.2),
                      child: Icon(
                        Icons.cleaning_services,
                        color: _getStatusColor(duty.status),
                      ),
                    ),
                    title: Text(duty.roomName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Status: ${duty.status.name.toUpperCase()}'),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAssignDutyDialog,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Assign Duty'),
      ),
    );
  }
}