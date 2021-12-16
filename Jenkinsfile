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
        stage("Azure Login") {
            steps{
                script{
                    withCredentials([azureServicePrincipal('azure-credentials')]) {
                    sh 'az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID'
                    }
                }
            }
        }
        stage('Terraform Init for Second VM') {
            steps {
                dir('TerraformGroupProjectContainersVM') {
                    sh "terraform init"
                }
            }
        }
        stage('Terraform Apply for Second VM') {
           steps {
                dir('TerraformGroupProjectContainersVM') {
                    sh "terraform apply -refresh-only -auto-approve"
                }
            }      
        }
    }
}