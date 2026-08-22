package com.example.repository;

import java.util.List;

import org.springframework.data.mongodb.repository.MongoRepository;

import com.example.model.Duty;
import com.example.model.DutyStatus;


public interface DutyRepository extends MongoRepository<Duty, String> {
    
    // Spring automatically generates the database query for this just by reading the name!
    List<Duty> findByDepartment(String department);
    boolean existsByRoomName(String roomName);
    boolean existsByRoomNameAndStatusNot(String roomName, DutyStatus status);
}