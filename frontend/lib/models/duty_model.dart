enum DutyStatus { pending, completed, verified, rejected }

class Duty {
  final String id;
  final String roomName;
  final String department;
  DutyStatus status;
  final String? rejectionReason;
  
  final String? sweeperName;
  final String? facultyName;
  
  // NEW: Time tracking variables
  final String? completedTime;
  final String? verifiedTime;

  Duty({
    required this.id,
    required this.roomName,
    required this.department,
    this.status = DutyStatus.pending,
    this.rejectionReason,
    this.sweeperName,
    this.facultyName,
    this.completedTime,
    this.verifiedTime,
  });

  factory Duty.fromJson(Map<String, dynamic> json) {
    return Duty(
      id: json['id'],
      roomName: json['roomName'],
      department: json['department'],
      rejectionReason: json['rejectionReason'],
      sweeperName: json['sweeperName'],
      facultyName: json['facultyName'],
      completedTime: json['completedTime'],
      verifiedTime: json['verifiedTime'],
      status: DutyStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == json['status'].toString().toLowerCase(),
        orElse: () => DutyStatus.pending,
      ),
    );
  }
}