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
      const SnackBar(content: Text('Room Verified Successfully!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
    );
  }

  void _rejectTask(String dutyId) {
    final reasonController = TextEditingController();

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
              filled: true,
              fillColor: Colors.white,
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
                    const SnackBar(content: Text('Reason is required to reject.'), behavior: SnackBarBehavior.floating),
                  );
                  return;
                }
                Navigator.pop(context);
                setState(() {
                  _pendingVerifications.removeWhere((duty) => duty.id == dutyId);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task Rejected. Sweeper notified.'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
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
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _pendingVerifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_rounded, size: 80, color: Colors.green.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    'All Caught Up!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'There are no rooms waiting for verification.',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 20),
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