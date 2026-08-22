package com.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;

import com.mongodb.client.MongoClient;

@SpringBootApplication
public class DemoApplication {

	public static void main(String[] args) {
		ConfigurableApplicationContext context = SpringApplication.run(DemoApplication.class, args);

		// DIAGNOSTIC ONLY — safe to delete once you've confirmed the fix
		// worked (i.e. once this prints your Atlas hostname instead of
		// localhost). This reads the actual settings baked into the live
		// MongoClient bean itself, which is the most direct possible check —
		// no more inferring anything from property resolution.
		MongoClient client = context.getBean(MongoClient.class);
		System.out.println("=== MONGO CLIENT DIAGNOSTIC ===");
		System.out.println("Cluster hosts: " + client.getClusterDescription().getClusterSettings().getHosts());
		System.out.println("=== END MONGO CLIENT DIAGNOSTIC ===");
	}

}