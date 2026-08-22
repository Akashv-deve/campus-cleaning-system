# Stage 1: Build the Maven project
FROM maven:3.8.5-openjdk-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Run the Java application
FROM openjdk:17.0.1-jdk-slim
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

# Create a non-root user named "springuser" and switch to it
RUN useradd -m springuser
USER springuser

# The -Xmx300m flag strictly limits Java to 300MB RAM so Render doesn't crash it.
ENTRYPOINT ["java", "-Xmx300m", "-jar", "app.jar"]