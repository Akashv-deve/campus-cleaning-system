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
    public Duty updateDutyStatus(String id, DutyStatus newStatus, String rejectionReason) {
        Duty duty = dutyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Duty not found with ID: " + id));

        duty.setStatus(newStatus);
        
        // If rejected, save the reason. If not, clear any old reasons.
        if (newStatus == DutyStatus.REJECTED) {
            duty.setRejectionReason(rejectionReason);
        } else {
            duty.setRejectionReason(null); 
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
}