FROM eclipse-temurin:17-jdk

LABEL authors="chara"

WORKDIR /app

COPY target/EcoPortAPI-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","app.jar"]