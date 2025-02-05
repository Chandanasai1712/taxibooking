From tomcat:9 
MAINTAINER "cs"
COPY ./application/target/taxi-booking-1.0.1.war /usr/local/tomcat/webapps
EXPOSE 8080
