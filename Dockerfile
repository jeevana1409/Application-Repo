FROM maven:3.9.9-eclipse-temurin-21 AS builder

WORKDIR /app
COPY . .

RUN mvn clean package -DskipTests

FROM tomcat:10-jdk21

# ✅ CORRECT PATH
COPY --from=builder /app/webapp/target/webapp.war /usr/local/tomcat/webapps/
