// lib/widgets/room_card.dart
import 'package:flutter/material.dart';
import '../models/duty_model.dart';

class RoomCard extends StatelessWidget {
  final Duty duty;
  final VoidCallback onComplete;

  const RoomCard({
    super.key,
    required this.duty,
    required this.onComplete,
  });

  Color _getStatusColor() {
    switch (duty.status) {
      case DutyStatus.pending:
        return Colors.orange;
      case DutyStatus.completed:
        return Colors.blue;
      case DutyStatus.verified:
        return Colors.green;
      case DutyStatus.rejected:
        return Colors.red;
    }
  }

  String _getStatusText() {
    return duty.status.name.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  duty.roomName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(
                    _getStatusText(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: _getStatusColor(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              duty.department,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            
            // Show rejection reason if the task was rejected
            if (duty.status == DutyStatus.rejected && duty.rejectionReason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Reason: ${duty.rejectionReason}',
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
            
            // Only show the "Complete" button if it's pending or rejected
            if (duty.status == DutyStatus.pending || duty.status == DutyStatus.rejected)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark as Completed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}