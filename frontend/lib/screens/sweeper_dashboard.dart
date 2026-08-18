// lib/screens/sweeper_dashboard.dart
import 'package:flutter/material.dart';
import '../models/duty_model.dart';
import '../widgets/room_card.dart';

class SweeperDashboard extends StatefulWidget {
  const SweeperDashboard({super.key});

  @override
  State<SweeperDashboard> createState() => _SweeperDashboardState();
}

class _SweeperDashboardState extends State<SweeperDashboard> {
  // MOCK DATA: Simulating what the backend will send us
  final List<Duty> _assignedDuties = [
    Duty(id: '1', roomName: 'CSE Lab 1', department: 'Computer Science'),
    Duty(id: '2', roomName: 'Classroom 302', department: 'Mechanical'),
    Duty(
      id: '3', 
      roomName: 'Physics Lab', 
      department: 'Science', 
      status: DutyStatus.rejected,
      rejectionReason: 'Dust found on the lab tables and windows not closed.',
    ),
    Duty(id: '4', roomName: 'Staff Room A', department: 'Admin', status: DutyStatus.completed),
  ];

  // Logic to handle button click
  void _markAsCompleted(String dutyId) {
    setState(() {
      // Find the duty and update its status
      final dutyIndex = _assignedDuties.indexWhere((d) => d.id == dutyId);
      if (dutyIndex != -1) {
        _assignedDuties[dutyIndex].status = DutyStatus.completed;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Room marked as completed. Waiting for verification.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cleaning Duties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Tasks for Today',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _assignedDuties.length,
              itemBuilder: (context, index) {
                final duty = _assignedDuties[index];
                return RoomCard(
                  duty: duty,
                  onComplete: () => _markAsCompleted(duty.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}