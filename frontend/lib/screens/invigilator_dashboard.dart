// lib/screens/invigilator_dashboard.dart
import 'package:flutter/material.dart';
import '../models/duty_model.dart';
import '../widgets/verification_card.dart';

class InvigilatorDashboard extends StatefulWidget {
  const InvigilatorDashboard({super.key});

  @override
  State<InvigilatorDashboard> createState() => _InvigilatorDashboardState();
}

class _InvigilatorDashboardState extends State<InvigilatorDashboard> {
  // MOCK DATA: Simulating tasks the backend says are "completed" and waiting for check
  final List<Duty> _pendingVerifications = [
    Duty(id: '1', roomName: 'CSE Lab 1', department: 'Computer Science', status: DutyStatus.completed),
    Duty(id: '2', roomName: 'Classroom 302', department: 'Mechanical', status: DutyStatus.completed),
    Duty(id: '3', roomName: 'Staff Room A', department: 'Admin', status: DutyStatus.completed),
  ];

  void _verifyTask(String dutyId) {
    setState(() {
      _pendingVerifications.removeWhere((duty) => duty.id == dutyId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Room Verified Successfully!'), backgroundColor: Colors.green),
    );
  }

  void _rejectTask(String dutyId) {
    final reasonController = TextEditingController();

    // Show a dialog to get the rejection reason
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject Cleaning'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: 'Enter reason (e.g., Dust on windows)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reason is required to reject.')),
                  );
                  return;
                }
                
                // Close dialog and remove task from list
                Navigator.pop(context);
                setState(() {
                  _pendingVerifications.removeWhere((duty) => duty.id == dutyId);
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task Rejected. Sweeper notified.'), backgroundColor: Colors.red),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Submit Rejection'),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Verifications'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _pendingVerifications.isEmpty
          ? const Center(
              child: Text(
                'All rooms verified!\nGreat job.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 16),
              itemCount: _pendingVerifications.length,
              itemBuilder: (context, index) {
                final duty = _pendingVerifications[index];
                return VerificationCard(
                  duty: duty,
                  onVerify: () => _verifyTask(duty.id),
                  onReject: () => _rejectTask(duty.id),
                );
              },
            ),
    );
  }
}