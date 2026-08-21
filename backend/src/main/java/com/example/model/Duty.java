package com.example.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Document(collection = "duties") // This tells MongoDB to store these in a 'duties' collection
public class Duty {
    
    @Id
    private String id; 
    
    private String roomName;
    private String department;
    
    @Builder.Default
    private DutyStatus status = DutyStatus.PENDING; // Matches your Dart default
    
    private String rejectionReason;
    private String sweeperName;
    private String facultyName;
}