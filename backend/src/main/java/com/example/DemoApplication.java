package com.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication {

    public static void main(String[] args) {

        String mongoUri = System.getenv("MONGODB_URI");

System.out.println("MONGODB_URI present: " +
        (mongoUri != null && !mongoUri.isBlank()));

if (mongoUri != null) {
    System.out.println("MONGODB_URI starts with mongodb+srv:// : " +
            mongoUri.startsWith("mongodb+srv://"));
    System.out.println("MONGODB_URI length: " + mongoUri.length());
}

        SpringApplication.run(DemoApplication.class, args);
    }
}