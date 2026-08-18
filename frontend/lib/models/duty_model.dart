// lib/models/duty_model.dart

enum DutyStatus { pending, completed, verified, rejected }

class Duty {
  final String id;
  final String roomName;
  final String department;
  DutyStatus status;
  String? rejectionReason; // Only used if status is rejected

  Duty({
    required this.id,
    required this.roomName,
    required this.department,
    this.status = DutyStatus.pending,
    this.rejectionReason,
  });
}