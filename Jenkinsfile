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
                echo 'Running Real Static Code Analysis...'
                // Yahan YOUR_TOKEN ki jagah apna SonarQube ka token daalna hai
                sh 'dotnet sonarscanner begin /k:"MyDevOpsProject" /d:sonar.host.url="http://localhost:9000" /d:sonar.login="YOUR_TOKEN"'
                sh 'dotnet build "MyDevOpsProject.csproj"'
                sh 'dotnet sonarscanner end /d:sonar.login="sqa_973cb53575b7804669c0ea881994528bfb0566f4"'
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
                echo 'Running Real Vulnerability Scan...'
                // Yeh command real mein scan karegi aur error aane par fail hogi
                sh "trivy image --severity HIGH,CRITICAL ${IMAGE_NAME}:latest"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing to Docker Hub...'
                withCredentials([usernamePassword(credentialsId: 'dockerhub-id', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    // Windows ke %VAR% ko Linux ke $VAR se replace kiya gaya hai
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh "docker push ${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                echo 'Deploying to Kubernetes Cluster...'
                sh "kubectl apply -f k8s.yaml"
            }
        }
    }
}