// lib/widgets/room_card.dart
//
// NOTE: The original source for this widget wasn't provided alongside the
// dashboards, so this is a fresh implementation built to match the exact
// call signature used in sweeper_dashboard.dart:
//   RoomCard(duty: duty, onComplete: () => _markAsCompleted(duty.id))
// It relies only on the same Duty/DutyStatus fields already used elsewhere
// (id, roomName, department, status, rejectionReason) — no model changes.
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

  _StatusStyle _statusStyle() {
    switch (duty.status) {
      case DutyStatus.pending:
        return _StatusStyle(
          color: const Color(0xFFEF6C00),
          bg: const Color(0xFFFFF3E0),
          label: 'TO DO',
          icon: Icons.pending_actions_rounded,
        );
      case DutyStatus.completed:
        return _StatusStyle(
          color: const Color(0xFF1565C0),
          bg: const Color(0xFFE3F2FD),
          label: 'WAITING FOR CHECK',
          icon: Icons.hourglass_top_rounded,
        );
      case DutyStatus.verified:
        return _StatusStyle(
          color: const Color(0xFF2E7D32),
          bg: const Color(0xFFE8F5E9),
          label: 'VERIFIED',
          icon: Icons.verified_rounded,
        );
      case DutyStatus.rejected:
        return _StatusStyle(
          color: const Color(0xFFC62828),
          bg: const Color(0xFFFFEBEE),
          label: 'NEEDS REDO',
          icon: Icons.error_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle();
    final bool canAct = duty.status == DutyStatus.pending || duty.status == DutyStatus.rejected;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.color.withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: style.bg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(style.icon, color: style.color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      duty.roomName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      duty.department,
                      style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: style.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              style.label,
              style: TextStyle(
                color: style.color,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (duty.status == DutyStatus.rejected && duty.rejectionReason != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_rounded, color: Color(0xFFC62828), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      duty.rejectionReason!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFFB71C1C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          if (canAct)
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton.icon(
                onPressed: onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                icon: const Icon(Icons.check_circle_rounded, size: 32),
                label: Text(
                  duty.status == DutyStatus.rejected ? 'MARK AS REDONE' : 'MARK AS COMPLETED',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.3),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: style.bg,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  duty.status == DutyStatus.verified ? 'Great job — verified!' : 'Waiting for teacher to check',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: style.color),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusStyle {
  final Color color;
  final Color bg;
  final String label;
  final IconData icon;

  _StatusStyle({required this.color, required this.bg, required this.label, required this.icon});
}