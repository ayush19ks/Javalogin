# pull base image
FROM tomcat:8-jre8

# Maintainer
MAINTAINER "ayush19ks@gmail.com"

# copy war file onto a container
ADD ./target/valaxy-2.0-RELEASE.war /usr/local/tomcat/webapps

EXPOSE 8080

CMD ["catalina.sh", "run"]
========================================
---------------------------

kubeadm join 172.31.9.11:6443 --token yjztae.906uwsjcz4x610pq \
        --discovery-token-ca-cert-hash sha256:87fb857ba8571c47e853e37738a9345290d55f0667720350f3c55b1b99181516

//



kubeadm join 172.31.9.11:6443 --token yjztae.906uwsjcz4x610pq \
        --discovery-token-ca-cert-hash sha256:87fb857ba8571c47e853e37738a9345290d55f0667720350f3c55b1b99181516					





==========================================
---------------------------------------------------------


pipeline {
    agent any
    tools {
        maven "Maven"
    }
    environment {
        PATH = "$PATH:/usr/share/maven"
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "13.233.158.37:8081:8081"
        NEXUS_REPOSITORY = "maven-nexus-repo"
        NEXUS_CREDENTIAL_ID = "nexus-user-credentials"
    }
    stages {
        stage('SCM'){
            steps{
                git 'https://github.com/ayush19ks/javaloginapp.git'
            }
         }
        stage("Maven Build") {
            steps {
                    sh "mvn package -DskipTests=true"
                }
            }
        stage("Publish to Nexus Repository Manager") {
            steps {
                script {
                    pom = readMavenPom file: "pom.xml";
                    filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                    echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                    artifactPath = filesByGlob[0].path;
                    artifactExists = fileExists artifactPath;
                    if(artifactExists) {
                        echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}";
                        nexusArtifactUploader(
                            nexusVersion: NEXUS_VERSION,
                            protocol: NEXUS_PROTOCOL,
                            nexusUrl: NEXUS_URL,
                            groupId: pom.groupId,
                            version: pom.version,
                            repository: NEXUS_REPOSITORY,
                            credentialsId: NEXUS_CREDENTIAL_ID,
                            artifacts: [
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: artifactPath,
                                type: pom.packaging],
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: "pom.xml",
                                type: "pom"]
                            ]
                        );
                    } else {
                        error "*** File: ${artifactPath}, could not be found";
                    }
                }
            }
        }
        stage('Docker Build and Tag') {
            steps {
                sh 'docker build -t javaloginapp:latest .' 
                sh 'docker tag javaloginapp zmuuyak/javaloginapp:latest'
                //sh 'docker tag javaloginapp zmuuyak/javaloginapp:$BUILD_NUMBER'     
          }
        }
        stage('Publish image to Docker Hub') {
            steps {
                withCredentials([string(credentialsId: 'docker-hub', variable: 'dockerHubpasswd')]) {
    // some block
                sh "docker login -u zmuuyak -p ${dockerHubpasswd}"
                sh  'docker push zmuuyak/javaloginapp:latest'
        //  sh  'docker push zmuuyak/javaloginapp:$BUILD_NUMBER' 
        }         
          }
        }
         stage('Deploy to Kubernetes'){
	sshagent(['kubernetes-client']) {
	   sh "scp -o StrictHostKeyChecking=no deployments.yml ec2-user@xxxxxxxxx:/home/ec2-user/"
	   try{
	     sh "ssh ec2-user@xxxxxxxxxx kubectl create -f /home/ec2-user/deployments.yml"
	   }catch(ex){
	     sh "ssh ec2-user@xxxxxxxxxx kubectl apply -f /home/ec2-user/deployments.yml"
	   }
	}
   }

172.31.23.138