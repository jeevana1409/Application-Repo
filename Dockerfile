# Build stage
FROM maven:3.9.9-eclipse-temurin-21 AS builder

WORKDIR /app
COPY . .

RUN mvn clean package -DskipTests

# Run stage
FROM tomcat:10-jdk21

COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/
