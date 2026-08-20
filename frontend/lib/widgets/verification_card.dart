// lib/widgets/verification_card.dart
//
// NOTE: The original source for this widget wasn't provided alongside the
// dashboards, so this is a fresh implementation built to match the exact
// call signature used in invigilator_dashboard.dart:
//   VerificationCard(duty: duty, onVerify: onVerify, onReject: onReject)
// Only the same Duty fields already used elsewhere are read
// (roomName, department) — no model changes.
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/duty_model.dart';

class VerificationCard extends StatelessWidget {
  final Duty duty;
  final VoidCallback onVerify;
  final VoidCallback onReject;

  const VerificationCard({
    super.key,
    required this.duty,
    required this.onVerify,
    required this.onReject,
  });

  // Soft pastel accent derived from department name, purely cosmetic.
  List<Color> _accent() {
    const palettes = [
      [Color(0xFFE3F2FD), Color(0xFF1565C0)],
      [Color(0xFFF3E5F5), Color(0xFF6A1B9A)],
      [Color(0xFFE0F2F1), Color(0xFF00695C)],
      [Color(0xFFFFF3E0), Color(0xFFE65100)],
      [Color(0xFFFCE4EC), Color(0xFFAD1457)],
    ];
    final idx = duty.department.hashCode.abs() % palettes.length;
    return palettes[idx];
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent();

    return Dismissible(
      key: ValueKey(duty.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onVerify();
        } else {
          onReject();
        }
        // The parent screen owns list mutation via setState, so we never
        // let Dismissible remove the item itself.
        return false;
      },
      background: _swipeBackground(
        alignment: Alignment.centerLeft,
        color: const Color(0xFF2E7D32),
        icon: Icons.check_circle_rounded,
        label: 'Verify',
      ),
      secondaryBackground: _swipeBackground(
        alignment: Alignment.centerRight,
        color: const Color(0xFFC62828),
        icon: Icons.cancel_rounded,
        label: 'Reject',
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.92),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.black.withValues(alpha:0.04)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: accent[0],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(Icons.meeting_room_rounded, color: accent[1], size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            duty.roomName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: accent[0],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              duty.department,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: accent[1],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.swipe_rounded, size: 18, color: Colors.grey.shade300),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFC62828),
                          side: const BorderSide(color: Color(0xFFFFCDD2), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onVerify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Verify', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _swipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    final bool isLeft = alignment == Alignment.centerLeft;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: alignment,
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isLeft
            ? [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ]
            : [
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Icon(icon, color: color),
              ],
      ),
    );
  }
}