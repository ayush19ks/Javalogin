# pull base image
FROM tomcat:8-jre8

# Maintainer
MAINTAINER "ayush19ks@gmail.com"

# copy war file onto a container
ADD ./target/valaxy-2.0-RELEASE.war /usr/local/tomcat/webapps

EXPOSE 8080

CMD ["catalina.sh", "run"]