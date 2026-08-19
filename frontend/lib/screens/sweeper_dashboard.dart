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

  void _markAsCompleted(String dutyId) {
    setState(() {
      final dutyIndex = _assignedDuties.indexWhere((d) => d.id == dutyId);
      if (dutyIndex != -1) {
        _assignedDuties[dutyIndex].status = DutyStatus.completed;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Room marked as completed. Waiting for verification.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating, // Makes it look modern
      ),
    );
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    // Calculate progress
    int totalDuties = _assignedDuties.length;
    int completedDuties = _assignedDuties.where((d) => d.status == DutyStatus.completed || d.status == DutyStatus.verified).length;
    double progress = totalDuties == 0 ? 0 : completedDuties / totalDuties;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Duties'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NEW: Progress Header
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Daily Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('$completedDuties / $totalDuties Rooms', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.indigo)),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.indigo.shade100,
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
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