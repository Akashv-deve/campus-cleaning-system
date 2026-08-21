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
        return data.map((json) => Duty.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load duties');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  // 2. Update a duty status
  static Future<void> updateStatus(String dutyId, DutyStatus status, {String? rejectionReason}) async {
    try {
      // Get exact device hardware time
      final now = DateTime.now();
      int hour = now.hour;
      final amPm = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      final minute = now.minute.toString().padLeft(2, '0');
      final timeString = "${now.day}/${now.month}, $hour:$minute $amPm";

      final body = {
        'status': status.name, // <-- Automatically converts enum to string!
        'timestamp': timeString, // <-- Sends the phone's hardware time!
      };
      
      if (rejectionReason != null) body['rejectionReason'] = rejectionReason;

      final response = await http.patch(
        Uri.parse('$baseUrl/$dutyId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update status');
      }
    } catch (e) {
      throw Exception('Error updating status: $e');
    }
  }
  // 3. (Admin) Create a new duty and assign both Sweeper and Faculty instantly
  static Future<void> createDuty(String roomName, String department, String sweeperName, String facultyName) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'roomName': roomName,
          'department': department,
          'sweeperName': sweeperName, 
          'facultyName': facultyName, // <-- Spring Boot will auto-save this!
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create duty');
      }
    } catch (e) {
      throw Exception('Error creating duty: $e');
    }
  }

  // 4. (Admin) Update both Sweeper and Faculty on an existing duty
  static Future<void> updateAssignment(String dutyId, String sweeperName, String facultyName) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$dutyId/assignment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sweeperName': sweeperName,
          'facultyName': facultyName,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update assignment');
      }
    } catch (e) {
      throw Exception('Error updating assignment: $e');
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
}