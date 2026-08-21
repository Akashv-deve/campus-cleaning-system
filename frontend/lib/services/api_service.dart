import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/duty_model.dart';

class ApiService {
  // IMPORTANT: 10.0.2.2 is how the Android Emulator connects to your PC's localhost!
  // (If you are using a real phone plugged in via USB, you must use your PC's actual Wi-Fi IP address instead).
  static const String baseUrl = 'http://10.0.2.2:8080/api/duties';

  // 1. Fetch duties for the Sweeper/Invigilator
  static Future<List<Duty>> getDutiesByDepartment(String department) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/department/$department'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => _fromJson(json)).toList();
      } else {
        throw Exception('Failed to load duties');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  // 2. Update a duty status
  static Future<void> updateStatus(String dutyId, DutyStatus newStatus, {String? rejectionReason}) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$dutyId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'status': newStatus.name, // Sends 'completed', 'verified', etc.
          'rejectionReason': rejectionReason,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update status');
      }
    } catch (e) {
      throw Exception('Error updating status: $e');
    }
  }

  // --- Helper method to convert JSON from Spring Boot into your Dart Object ---
  static Duty _fromJson(Map<String, dynamic> json) {
    return Duty(
      id: json['id'],
      roomName: json['roomName'],
      department: json['department'],
      status: DutyStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == json['status'].toString().toLowerCase(),
        orElse: () => DutyStatus.pending,
      ),
      rejectionReason: json['rejectionReason'],
    );
  }
}