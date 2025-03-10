pipeline {

    agent { node { label 'slave' } }

    tools { terraform 'terraform' }
    
    environment {
        WORKDIR = 'eks-infra'
        BUCKET_NAME = 'application-eks-terraform'
    }
    
    parameters {
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Choose Terraform action to perform')
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Fetching Infra code from GitHub'
                git branch: 'main', url: 'https://github.com/saishandilya/taxi-booking-terraform-infra.git'
                script {
                    env.GIT_COMMIT = sh(script: "git rev-parse HEAD", returnStdout: true).trim()
                    echo "Current Git Commit ID: ${env.GIT_COMMIT}"
                }
            }
        }

        stage('Terraform Init') {
            steps {
                echo 'Terraform Initiation...!!!'
                dir("${WORKDIR}") {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                echo 'Terraform code Validation...!!!'
                dir("${WORKDIR}") {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                echo 'Terraform Planning...!!!'
                dir("${WORKDIR}") {
                    script {
                        env.PLAN_NAME = "eks-infra-plan-" + sh(script: 'date +%Y%m%d-%H%M%S', returnStdout: true).trim() + ".plan"
                    }
                    echo "${env.PLAN_NAME}"
                    withCredentials([file(credentialsId: 'terraform-tfvars', variable: 'TFVARS_FILE')]) {
                        sh "terraform plan -var-file=\$TFVARS_FILE -out=\"${env.PLAN_NAME}\""
                        sh "aws s3 cp ${env.PLAN_NAME} s3://${BUCKET_NAME}/terraform-plan/"
                    }
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                echo 'Terraform Applying Infrastructure Plan...!!!'
                dir("${WORKDIR}") {
                    sh """
                        if [ ! -f "${env.PLAN_NAME}" ]; then
                            echo "ERROR: Plan file not found: ${env.PLAN_NAME}" >&2
                            exit 1
                        fi

                        terraform apply "${env.PLAN_NAME}"
                    """
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                echo 'Terraform Destroying Infrastructure...!!!'
                dir("${WORKDIR}") {
                    withCredentials([file(credentialsId: 'terraform-tfvars', variable: 'TFVARS_FILE')]) {
                        sh 'terraform destroy -var-file=$TFVARS_FILE -auto-approve'
                    }
                }
            }
        }
    }
}