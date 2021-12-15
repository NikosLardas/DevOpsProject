pipeline {
    agent any

    environment{
        imagename = "nlardas/devopsgroupproject"
        dockerImage = ''
        dockercredentials = 'dockerhub-credentials'
    }

    stages {
        stage('Create Jar file with Maven') {
            steps {
                sh 'mvn package'
            } 
        }
        stage("Create docker image") {
            steps{
                script{
                    dockerImage = docker.build imagename
                }
            }   
        }
        stage("Push image to registry"){
            steps{
                script{
                    docker.withRegistry('',dockercredentials){
                        dockerImage.push("$BUILD_NUMBER")
                        dockerImage.push('latest')
                    }
                }
            }
        }
    }
}