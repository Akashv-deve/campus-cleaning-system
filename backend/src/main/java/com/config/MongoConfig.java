package com.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;

@Configuration
public class MongoConfig {

    // We're defining this bean explicitly instead of letting
    // MongoAutoConfiguration build it implicitly. The diagnostic proved
    // Spring's Environment resolves spring.data.mongodb.uri to the correct
    // Atlas connection string — but the auto-configured MongoClient bean was
    // still being built with driver defaults (hosts=[localhost:27017]),
    // meaning the auto-configuration path wasn't actually using that
    // resolved value by the time it built the client.
    //
    // Defining our own @Bean here sidesteps whatever is going wrong in that
    // path entirely: Spring Boot's MongoAutoConfiguration is
    // @ConditionalOnMissingBean(MongoClient.class), so it backs off the
    // moment a MongoClient bean already exists, and this one is built
    // directly from the exact string @Value injects — no intermediate
    // MongoProperties binding step for the client itself.
    @Bean
    public MongoClient mongoClient(@Value("${spring.data.mongodb.uri}") String uri) {
        return MongoClients.create(uri);
    }
}