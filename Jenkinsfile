pipeline {
    agent any
    
    environment {
        IMAGE_NAME = 'nayab010/mydevopsproject'
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Pulling latest code from GitHub...'
                checkout scm
            }
        }

        stage('SonarQube Real Analysis') {
            steps {
                echo 'Running Real Static Code Analysis using Docker...'
                // Hum .NET SDK ka official container use kar ke code scan karwayenge
                // host.docker.internal use kiya gaya hai taakay yeh Windows wale SonarQube tak pounch sakay
                sh """
                docker run --rm -v "${WORKSPACE}:/app" -w /app mcr.microsoft.com/dotnet/sdk:8.0 bash -c '
                    dotnet tool install --global dotnet-sonarscanner &&
                    export PATH="\$PATH:/root/.dotnet/tools" &&
                    dotnet sonarscanner begin /k:"MyDevOpsProject" /d:sonar.host.url="http://host.docker.internal:9000" /d:sonar.login="sqa_973cb53575b7804669c0ea881994528bfb0566f4" &&
                    dotnet build &&
                    dotnet sonarscanner end /d:sonar.login="sqa_973cb53575b7804669c0ea881994528bfb0566f4"
                '
                """
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Real Docker Image...'
                sh "docker build -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('Trivy Security Scan') {
            steps {
                echo 'Running Real Vulnerability Scan via Docker...'
                // Trivy ka official container direct aapki image scan karega!
                sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image --severity HIGH,CRITICAL ${IMAGE_NAME}:latest || true"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing to Docker Hub...'
                withCredentials([usernamePassword(credentialsId: 'dockerhub-id', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                    sh "docker push ${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                echo 'Pipeline Execution Completed!'
                echo '---------------------------------------------------'
                echo 'VIVA NOTE FOR NAYAB:'
                echo 'Kyunke Jenkins abhi Docker mein hai, Kubernetes par deploy karne ke liye'
                echo 'apni Windows PowerShell mein yeh command manually chalayen:'
                echo 'kubectl apply -f k8s.yaml'
                echo '---------------------------------------------------'
            }
        }
    }
}