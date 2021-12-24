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
                sh "az login -u nlardas2@athtech.gr -p DevOpsProject21"
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
                    sh "terraform apply -auto-approve"
                }
            }      
        }
        stage('Execute Ansible Playbook') {
            steps {
                script {
                    ansiblePlaybook credentialsId: 'ansible-credential', inventory: 'AnsibleGroupProject/inventory.yml', playbook: 'AnsibleGroupProject/devops-group-project-playbook.yml' -vvv
                }
            }
        }
    }
}
