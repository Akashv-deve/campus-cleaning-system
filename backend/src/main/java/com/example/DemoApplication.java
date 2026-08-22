package com.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication {

    public static void main(String[] args) {
        System.out.println("MONGODB_URI present: " +
                (System.getenv("MONGODB_URI") != null &&
                 !System.getenv("MONGODB_URI").isBlank()));

        SpringApplication.run(DemoApplication.class, args);
    }
}