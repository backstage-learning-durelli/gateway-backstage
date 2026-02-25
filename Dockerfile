# Stage 1: Build
FROM eclipse-temurin:17-jdk-jammy AS build
WORKDIR /app

# Copiar pom.xml e código fonte
COPY pom.xml .
COPY src ./src

# Instalar Maven e compilar aplicação
RUN apt-get update && apt-get install -y maven && apt-get clean
RUN mvn clean package -DskipTests

# Stage 2: Runtime
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Copiar JAR compilado do estágio de build
COPY --from=build /app/target/*.jar app.jar

# Expor porta do gateway
EXPOSE 8080

# Health check usando wget e actuator endpoint
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Executar aplicação
ENTRYPOINT ["java", "-jar", "app.jar"]
