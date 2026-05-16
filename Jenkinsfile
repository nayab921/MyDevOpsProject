pipeline {
    agent any
    
    environment {
        IMAGE_NAME = 'nayab010/mydevopsproject'
        // NuGet timeout ko 10 minutes tak barha diya gaya hai
        DOTNET_HTTP_TIMEOUT = '600'
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
                echo 'Running Full Static Analysis and Project Build...'
                sh '''
                tar -cf - . | docker run --rm -i --dns 8.8.8.8 -e DOTNET_HTTP_TIMEOUT=600 -w /app mcr.microsoft.com/dotnet/sdk:8.0 bash -c '
                    tar -xf - &&
                    dotnet tool install --global dotnet-sonarscanner --version 5.15.0 &&
                    export PATH="$PATH:/root/.dotnet/tools" &&
                    PROJECT_FILE=$(find . -name "*.csproj" | head -n 1) &&
                    
                    echo "Starting SonarScanner..." &&
                    dotnet sonarscanner begin /k:"MyDevOpsProject" /d:sonar.host.url="http://192.168.100.235:9000" /d:sonar.login="sqa_973cb53575b7804669c0ea881994528bfb0566f4" &&
                    
                    echo "Restoring Packages (Increased Timeout)..." &&
                    dotnet restore "$PROJECT_FILE" --disable-parallel --no-cache &&
                    
                    echo "Building Project..." &&
                    dotnet build "$PROJECT_FILE" --no-restore -c Release &&
                    
                    echo "Closing SonarScanner..." &&
                    dotnet sonarscanner end /d:sonar.login="sqa_973cb53575b7804669c0ea881994528bfb0566f4"
                '
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Creating Production Docker Image...'
                sh "chmod 777 /var/run/docker.sock || true"
                sh "docker build -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('Trivy Security Scan') {
            steps {
                echo 'Performing Deep Security Scan...'
                // Isay hum real rakhenge, agar vulnerabilities zyada huin toh report show hogi
                sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image --severity HIGH,CRITICAL ${IMAGE_NAME}:latest"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing Image to Docker Hub...'
                // Make sure aapne Jenkins mein 'dockerhub-id' ke naam se credentials banaye hain
                withCredentials([usernamePassword(credentialsId: 'dockerhub-id', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh "docker push ${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Triggering Kubernetes Deployment...'
                // Kyunke Jenkins container mein hai, hum Windows ke kubectl ko direct touch nahi kar sakte
                // Viva mein explain karne ke liye ye best professional approach hai
                echo "Deployment manifest (k8s.yaml) is ready."
                echo "Run: kubectl apply -f k8s.yaml in your Windows terminal."
            }
        }
    }
}