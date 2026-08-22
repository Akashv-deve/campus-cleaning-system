package com.example.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.model.Duty;
import com.example.model.DutyStatus;
import com.example.repository.DutyRepository;
import com.example.service.DutyService;

import lombok.RequiredArgsConstructor;
@RestController
@RequestMapping("/api/duties")
@CrossOrigin(origins = "*") // Crucial: Allows your Flutter emulator to talk to the backend
@RequiredArgsConstructor
public class DutyController {

    private final DutyService dutyService;
    private final DutyRepository dutyRepository;

    // 1. Get duties for a specific department (For Sweeper & Invigilator Dashboards)
    @GetMapping("/department/{department}")
    public ResponseEntity<List<Duty>> getDutiesByDepartment(@PathVariable String department) {
        return ResponseEntity.ok(dutyService.getDutiesByDepartment(department));
    }

    // 2. Update status (When a Sweeper clicks "Completed" or Invigilator clicks "Verified"/"Rejected")
    @PatchMapping("/{id}/status")
    public ResponseEntity<Duty> updateStatus(
            @PathVariable String id,
            @RequestBody Map<String, String> requestBody) {
        
        DutyStatus newStatus = DutyStatus.valueOf(requestBody.get("status").toUpperCase());
        String rejectionReason = requestBody.get("rejectionReason"); 
        String timestamp = requestBody.get("timestamp"); // Catch the phone's time!
        
        Duty updatedDuty = dutyService.updateDutyStatus(id, newStatus, rejectionReason, timestamp);
        return ResponseEntity.ok(updatedDuty);
    }
    
    // 3. (Admin) Get all duties across the campus
    @GetMapping
    public ResponseEntity<List<Duty>> getAllDuties() {
        return ResponseEntity.ok(dutyService.getAllDuties());
    }
    
    // 4. (Admin) Create a new duty assignment
    @PostMapping
    public ResponseEntity<?> createDuty(@RequestBody Duty duty) {
        // Check if the room already has a Pending or Completed task
        boolean hasActiveDuty = dutyRepository.existsByRoomNameAndStatusNot(duty.getRoomName(), DutyStatus.verified);
        
        if (hasActiveDuty) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body("This room already has an active duty pending verification!");
        }
        return ResponseEntity.ok(dutyService.createDuty(duty));
    }
    // 5. (Admin) Allot a faculty member to an existing duty
    @PatchMapping("/{id}/faculty")
    public ResponseEntity<Duty> allotFaculty(
            @PathVariable String id,
            @RequestBody Map<String, String> requestBody) {
        
        String facultyName = requestBody.get("facultyName");
        Duty updatedDuty = dutyService.allotFaculty(id, facultyName);
        return ResponseEntity.ok(updatedDuty);
    }
    // 6. (Admin) Permanently delete a duty
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteDuty(@PathVariable String id) {
        dutyService.deleteDuty(id);
        return ResponseEntity.ok().build();
    }
    // 7. (Admin) Update both Sweeper and Faculty assignments
    @PatchMapping("/{id}/assignment")
    public ResponseEntity<Duty> updateAssignment(
            @PathVariable String id,
            @RequestBody Map<String, String> requestBody) {
        
        String sweeperName = requestBody.get("sweeperName");
        String facultyName = requestBody.get("facultyName");
        
        Duty updatedDuty = dutyService.updateAssignment(id, sweeperName, facultyName);
        return ResponseEntity.ok(updatedDuty);
    }
}