package com.example.repository;

import java.util.List;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import com.example.model.Duty;

@Repository
public interface DutyRepository extends MongoRepository<Duty, String> {
    
    // Spring automatically generates the database query for this just by reading the name!
    List<Duty> findByDepartment(String department);
}