package com.example.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.model.Duty;
import com.example.model.DutyStatus;
import com.example.repository.DutyRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class DutyService {

    private final DutyRepository dutyRepository;

    // 1. Get all duties (For Admin Dashboard)
    public List<Duty> getAllDuties() {
        return dutyRepository.findAll();
    }

    // 2. Get duties for a specific department (For Sweeper/Invigilator)
    public List<Duty> getDutiesByDepartment(String department) {
        return dutyRepository.findByDepartment(department);
    }

    // 3. Create a new duty
    public Duty createDuty(Duty duty) {
        return dutyRepository.save(duty);
    }

    // 4. Update the status of a duty (Completed, Verified, Rejected)
    public Duty updateDutyStatus(String id, DutyStatus status, String rejectionReason, String timestamp) {
        Duty duty = dutyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Duty not found"));
        
        duty.setStatus(status);
        duty.setRejectionReason(rejectionReason);
        
        switch (status) {
            case COMPLETED:
                duty.setCompletedTime(timestamp);
                break;
            case VERIFIED:
                duty.setVerifiedTime(timestamp);
                break;
            case PENDING:
            case REJECTED:
                duty.setCompletedTime(null);
                duty.setVerifiedTime(null);
                break;
        }
        
        return dutyRepository.save(duty);
    }
    public Duty allotFaculty(String id, String facultyName) {
        Duty duty = dutyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Duty not found with id: " + id));
        
        duty.setFacultyName(facultyName);
        return dutyRepository.save(duty);
    }
    public void deleteDuty(String id) {
        dutyRepository.deleteById(id);
    }
    public Duty updateAssignment(String id, String sweeperName, String facultyName) {
        Duty duty = dutyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Duty not found with id: " + id));
        
        duty.setSweeperName(sweeperName);
        duty.setFacultyName(facultyName);
        return dutyRepository.save(duty);
    }
}