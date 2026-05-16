pipeline {
    agent any
    
    environment {
        IMAGE_NAME = 'nayab010/mydevopsproject'
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Pulling code...'
                checkout scm
            }
        }

        stage('SonarQube Real Scan & Build') {
            steps {
                echo 'Running Static Code Analysis and Build...'
                // Ab koi bypass nahi hai, yeh real analysis karega aur report upload karega
                sh '''
                tar -cf - . | docker run --rm -i --dns 8.8.8.8 -w /app mcr.microsoft.com/dotnet/sdk:8.0 bash -c '
                    tar -xf - &&
                    
                    echo "Installing Java (Required for SonarQube Report Upload)..." &&
                    apt-get update && apt-get install -y default-jre &&
                    
                    dotnet tool install --global dotnet-sonarscanner --version 5.15.0 &&
                    export PATH="$PATH:/root/.dotnet/tools" &&
                    PROJECT_FILE=$(find . -name "*.csproj" | head -n 1) &&
                    
                    echo "Starting Real SonarScanner..." &&
                    dotnet sonarscanner begin /k:"MyDevOpsProject" /d:sonar.host.url="http://192.168.100.235:9000" /d:sonar.login="sqa_973cb53575b7804669c0ea881994528bfb0566f4" &&
                    
                    echo "Restoring Packages safely..." &&
                    for i in {1..5}; do 
                        echo "Attempt $i..."
                        dotnet restore "$PROJECT_FILE" --disable-parallel --no-cache && break || echo "Retrying..."
                        sleep 2
                    done &&
                    
                    echo "Building Project..." &&
                    dotnet build "$PROJECT_FILE" --no-restore -c Release &&
                    
                    echo "Uploading Report to SonarQube..." &&
                    dotnet sonarscanner end /d:sonar.login="sqa_973cb53575b7804669c0ea881994528bfb0566f4"
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
                sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image --severity HIGH,CRITICAL ${IMAGE_NAME}:latest"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing to Docker Hub...'
                withCredentials([usernamePassword(credentialsId: 'dockerhub-id', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh "docker push ${IMAGE_NAME}:latest"
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