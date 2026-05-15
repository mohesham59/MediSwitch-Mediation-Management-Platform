# ================================================================
#  Telecom Mediation WebApp — Dockerfile
#  Java 17  |  Maven 3.9  |  Tomcat 11  |  Jakarta EE 10
# ================================================================

# ── Stage 1: Build ────────────────────────────────────────────────
FROM maven:3.9.6-eclipse-temurin-17-alpine AS build

WORKDIR /app

# Copy pom.xml first — Maven dependency layer is cached separately
# so rebuilds after a source-only change skip the download step
COPY pom.xml .
RUN mvn dependency:go-offline -q

# Copy source and build the WAR (skip tests for faster deploys)
COPY src ./src
RUN mvn clean package -q -DskipTests

# ── Stage 2: Run ──────────────────────────────────────────────────
FROM tomcat:11.0-jdk17

# Remove Tomcat's default sample webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Deploy WAR as ROOT so URLs are /login and /dashboard
# instead of /mediation-webapp/login and /mediation-webapp/dashboard
COPY --from=build /app/target/mediation-webapp.war \
                  /usr/local/tomcat/webapps/ROOT.war

# Render assigns a dynamic port via the PORT env variable (usually 10000).
# Tomcat must listen on that exact port or Render's health check fails.
# The sed command patches server.xml before Tomcat starts.
EXPOSE 8080

CMD ["catalina.sh", "run"]
