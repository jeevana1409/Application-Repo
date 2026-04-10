FROM tomcat:9.0-jdk17

# Remove default apps (recommended for production)
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy your application
COPY myapp.war /usr/local/tomcat/webapps/ROOT.war
