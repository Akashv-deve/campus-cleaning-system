enum DutyStatus { pending, completed, verified, rejected }

class Duty {
  final String id;
  final String roomName;
  final String department;
  DutyStatus status;
  final String? rejectionReason;
  
  // NEW: Real role-based tracking
  final String? sweeperName;
  final String? facultyName;

  Duty({
    required this.id,
    required this.roomName,
    required this.department,
    this.status = DutyStatus.pending,
    this.rejectionReason,
    this.sweeperName,
    this.facultyName,
  });

  factory Duty.fromJson(Map<String, dynamic> json) {
    return Duty(
      id: json['id'],
      roomName: json['roomName'],
      department: json['department'],
      rejectionReason: json['rejectionReason'],
      sweeperName: json['sweeperName'],
      facultyName: json['facultyName'],
      status: DutyStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == json['status'].toString().toLowerCase(),
        orElse: () => DutyStatus.pending,
      ),
    );
  }
}