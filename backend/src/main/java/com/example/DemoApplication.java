package com.example;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@SpringBootApplication
public class DemoApplication {

	private static final Logger log = LoggerFactory.getLogger(DemoApplication.class);

	public static void main(String[] args) {
		SpringApplication.run(DemoApplication.class, args);
	}

	// DIAGNOSTIC ONLY — safe to remove once the "localhost:27017" connection
	// issue is confirmed fixed. Prints (with credentials masked) exactly
	// which Mongo URI Spring resolved at startup, straight into the Render
	// logs. If this ever prints "localhost" instead of your Atlas hostname,
	// that means spring.data.mongodb.uri isn't reaching the app at
	// all — most likely an environment variable on Render (check the
	// Environment tab for a stray/blank MONGODB_URI or
	// SPRING_DATA_MONGODB_URI) is overriding application.properties, since
	// env vars always take precedence over the properties file.
	@Bean
	CommandLineRunner logResolvedMongoUri(@Value("${spring.data.mongodb.uri:NOT SET}") String mongoUri) {
		return args -> {
			String masked = mongoUri.replaceAll("://([^:]+):([^@]+)@", "://$1:****@");
			log.info(">>> Resolved Mongo URI at startup: {}", masked);
		};
	}

}