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
  // CSE-ONLY MOCK DATA
  final List<Duty> _assignedDuties = [
    Duty(id: '1', roomName: 'CSE Lab 1', department: 'CSE Dept'),
    Duty(id: '2', roomName: 'CSE Lab 2', department: 'CSE Dept'),
    Duty(
      id: '3',
      roomName: 'IoT Lab',
      department: 'CSE Dept',
      status: DutyStatus.rejected,
      rejectionReason: 'Dust found on the monitors and keyboards.',
    ),
    Duty(id: '4', roomName: 'HOD Cabin', department: 'CSE Dept', status: DutyStatus.completed),
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
        content: Text(
          'Room marked as completed. Waiting for verification.',
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final int totalDuties = _assignedDuties.length;
    final int completedDuties = _assignedDuties
        .where((d) => d.status == DutyStatus.completed || d.status == DutyStatus.verified)
        .length;
    final double progress = totalDuties == 0 ? 0 : completedDuties / totalDuties;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Duties Today',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            iconSize: 30,
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressHeader(completedDuties, totalDuties, progress),
          Expanded(
            child: _assignedDuties.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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

  Widget _buildProgressHeader(int completed, int total, double progress) {
    final bool allDone = total > 0 && completed == total;
    final String message = allDone
        ? "🎉 Amazing! All rooms done!"
        : completed == 0
            ? "Let's get started!"
            : "Great work — keep going!";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 84,
                height: 84,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => CircularProgressIndicator(
                        value: value,
                        strokeWidth: 10,
                        backgroundColor: Colors.white.withOpacity(0.25),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFA5D6A7)),
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$completed of $total rooms done',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => LinearProgressIndicator(
                          value: value,
                          minHeight: 14,
                          backgroundColor: Colors.white.withOpacity(0.25),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFA5D6A7)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_rounded, size: 96, color: Colors.amber.shade600),
            const SizedBox(height: 20),
            const Text(
              'No duties assigned yet.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check back soon — your rooms will show up here.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}