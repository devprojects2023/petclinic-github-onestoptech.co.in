
##------------------------------------------------------------------------------------------------------------------#

# FROM maven:3.6.3-openjdk-17
# # Set the working directory in the container
# WORKDIR /usr/src/app

# # Copy the Maven project files (pom.xml) to the container
# COPY pom.xml .

# # Copy the application source code to the container
# COPY . .

# # Build the application
# # RUN mvn clean install -DskipTests -Dcheckstyle.skip
# RUN mvn package -DskipTests -Dcheckstyle.skip

# EXPOSE 8080

# # Copy the JAR file into the image
# COPY target/spring-petclinic-3.2.0-SNAPSHOT.jar /usr/src/app

# # Set the entry point for the application
# CMD ["java", "-Dspring.profiles.active=mysql", "-jar", "/usr/src/app/target/spring-petclinic-3.2.0-SNAPSHOT.jar"]
##------------------------------------------------------------------------------------------------------------------#


# Build stage
FROM openjdk:17-jdk-alpine3.14 

# Set the working directory in the container
WORKDIR /app

# expose the port
EXPOSE 8080

# Copy the JAR file into the image
COPY target/spring-petclinic-3.2.0-SNAPSHOT.jar /app/

# Set the entry point for the application
CMD ["java", "-Dspring.profiles.active=mysql", "-jar", "/app/spring-petclinic-3.2.0-SNAPSHOT.jar"]