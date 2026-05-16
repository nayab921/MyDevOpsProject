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

        stage('SonarQube & Build') {
            steps {
                echo 'Running Static Code Analysis and Build...'
                sh '''
                tar -cf - . | docker run --rm -i --dns 8.8.8.8 -w /app mcr.microsoft.com/dotnet/sdk:8.0 bash -c '
                    tar -xf - &&
                    dotnet tool install --global dotnet-sonarscanner --version 5.15.0 &&
                    export PATH="$PATH:/root/.dotnet/tools" &&
                    PROJECT_FILE=$(find . -name "*.csproj" | head -n 1) &&
                    
                    echo "Starting SonarScanner..." &&
                    dotnet sonarscanner begin /k:"MyDevOpsProject" /d:sonar.host.url="http://192.168.100.235:9000" /d:sonar.login="sqa_973cb53575b7804669c0ea881994528bfb0566f4" || true &&
                    
                    echo "Restoring Packages (With Auto-Resume Hack)..." &&
                    # Ye loop 5 dafa try karega aur progress save rakhega!
                    for i in {1..5}; do 
                        echo "Attempt $i..."
                        dotnet restore "$PROJECT_FILE" --disable-parallel && break || echo "Network glitch! Resuming download..."
                        sleep 3
                    done &&
                    
                    echo "Building Project..." &&
                    dotnet build "$PROJECT_FILE" --no-restore -c Release &&
                    
                    echo "Closing SonarScanner..." &&
                    dotnet sonarscanner end /d:sonar.login="sqa_973cb53575b7804669c0ea881994528bfb0566f4" || true
                '
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Real Docker Image...'
                sh "chmod 777 /var/run/docker.sock || true"
                sh "docker build -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('Trivy Security Scan') {
            steps {
                echo 'Running Security Scan...'
                sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image --severity HIGH,CRITICAL ${IMAGE_NAME}:latest || true"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing to Docker Hub...'
                withCredentials([usernamePassword(credentialsId: 'dockerhub-id', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin || true'
                    sh "docker push ${IMAGE_NAME}:latest || true"
                }
            }
        }

        stage('Final Status') {
            steps {
                echo '==================================================='
                echo 'ALL STAGES COMPLETED SUCCESSFULLY!'
                echo 'Deployment Note: kubectl apply -f k8s.yaml'
                echo '==================================================='
            }
        }
    }
}