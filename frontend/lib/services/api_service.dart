import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/duty_model.dart';

class ApiService {
  // IMPORTANT: 10.0.2.2 is how the Android Emulator connects to your PC's localhost!
  // (If you are using a real phone plugged in via USB, you must use your PC's actual Wi-Fi IP address instead).
  static const String baseUrl = 'http://localhost:8080/api/duties';

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
  // 3. (Admin) Create a new duty and assign a Sweeper
  static Future<void> createDuty(String roomName, String department, String sweeperName) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'roomName': roomName,
          'department': department,
          'sweeperName': sweeperName, // Sending the exact sweeper name!
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create duty');
      }
    } catch (e) {
      throw Exception('Error creating duty: $e');
    }
  }

  // 4. (Admin) Allot a Faculty member to an existing duty
  static Future<void> allotFaculty(String dutyId, String facultyName) async {
    try {
      // We use PATCH to update the existing database row
      final response = await http.patch(
        Uri.parse('$baseUrl/$dutyId/faculty'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'facultyName': facultyName,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to allot faculty');
      }
    } catch (e) {
      throw Exception('Error allotting faculty: $e');
    }
  }
  // 5. (Admin) Delete a duty permanently
  static Future<void> deleteDuty(String dutyId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$dutyId'));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete duty');
      }
    } catch (e) {
      throw Exception('Error deleting duty: $e');
    }
  }
  // (Admin) Get all duties across the campus
  static Future<List<Duty>> getAllDuties() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        Iterable list = jsonDecode(response.body);
        return list.map((model) => Duty.fromJson(model)).toList();
      } else {
        throw Exception('Failed to load all duties');
      }
    } catch (e) {
      throw Exception('Error fetching all duties: $e');
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