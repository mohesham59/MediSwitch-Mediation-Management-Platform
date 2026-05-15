# ── Stage 1: build ────────────────────────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
# Download dependencies first (layer-cache friendly)
RUN mvn dependency:go-offline -q
COPY src ./src
RUN mvn package -DskipTests -q

# ── Stage 2: run ──────────────────────────────────────────────────────────────
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/MediationEngine-1.0.jar app.jar

# Paths are overridden at runtime via docker-compose environment: block
ENV UPSTREAM_BASE_PATH=/data/upstream
ENV DOWNSTREAM_BASE_PATH=/data/downstream

ENTRYPOINT ["java", "-jar", "app.jar"]
