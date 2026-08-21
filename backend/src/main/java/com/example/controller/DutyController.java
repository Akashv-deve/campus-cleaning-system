package com.example.controller;

import com.example.model.Duty;
import com.example.model.DutyStatus;
import com.example.service.DutyService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/duties")
@CrossOrigin(origins = "*") // Crucial: Allows your Flutter emulator to talk to the backend
@RequiredArgsConstructor
public class DutyController {

    private final DutyService dutyService;

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
        String rejectionReason = requestBody.get("rejectionReason"); // Will be null unless rejected
        
        Duty updatedDuty = dutyService.updateDutyStatus(id, newStatus, rejectionReason);
        return ResponseEntity.ok(updatedDuty);
    }
    
    // 3. (Admin) Get all duties across the campus
    @GetMapping
    public ResponseEntity<List<Duty>> getAllDuties() {
        return ResponseEntity.ok(dutyService.getAllDuties());
    }
    
    // 4. (Admin) Create a new duty assignment
    @PostMapping
    public ResponseEntity<Duty> createDuty(@RequestBody Duty duty) {
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
}