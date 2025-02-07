# JDK21 Image
FROM openjdk:21-jdk

ARG JAR_FILE=build/libs/*.jar
COPY ${JAR_FILE} simpleboard.jar
ENTRYPOINT ["java", "-jar", "/simpleboard.jar"]