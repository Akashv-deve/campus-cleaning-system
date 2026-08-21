package com.yourpackage.model; // Change to match your actual package name

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

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
    
    private String rejectionReason; // Java handles nullables automatically for Strings
}