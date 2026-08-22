package com.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.Environment;

@SpringBootApplication
public class DemoApplication {

	public static void main(String[] args) {
		ConfigurableApplicationContext context = SpringApplication.run(DemoApplication.class, args);

		// DIAGNOSTIC ONLY — safe to delete once this is resolved.
		//
		// Every test so far (System.getenv("MONGODB_URI")) has only proven
		// that the raw OS-level environment variable exists and looks right.
		// It has NOT proven that Spring's own Environment actually resolves
		// spring.data.mongodb.uri to that value — and that resolved property
		// is the ONLY thing MongoAutoConfiguration actually reads to build
		// the Mongo client. This asks that exact question directly, using
		// plain System.out (not a logger) so it can't get silently filtered
		// by a log-level config the way the previous CommandLineRunner
		// attempt apparently did.
		Environment env = context.getEnvironment();
		String resolved = env.getProperty("spring.data.mongodb.uri");

		System.out.println("=== MONGO DIAGNOSTIC ===");
		if (resolved == null) {
			System.out.println("spring.data.mongodb.uri resolved by Spring: NULL — property was not found at all.");
			System.out.println("This means application.properties on the deployed image either doesn't have");
			System.out.println("this exact key, or this build isn't picking up the file you think it is.");
		} else {
			String masked = resolved.replaceAll("://([^:]+):([^@]+)@", "://$1:****@");
			System.out.println("spring.data.mongodb.uri resolved by Spring: " + masked);
			System.out.println("Length: " + resolved.length());
			System.out.println("Contains 'localhost': " + resolved.toLowerCase().contains("localhost"));
		}
		System.out.println("=== END MONGO DIAGNOSTIC ===");
	}

}