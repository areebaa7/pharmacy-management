pipeline {
    agent any
    
    environment {
        DJANGO_SETTINGS_MODULE = 'pharmacy.settings'
        PYTHON_VERSION = '3.11'
        IMAGE_NAME = "areeba77/pharmacy-management"
        IMAGE_TAG = "${BUILD_ID}"
        DOCKER_USERNAME = "areeba77"
        DOCKER_PASSWORD = "cr7forevergoat"
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/areebaa7/pharmacy-management.git'
            }
        }
        
        stage('Setup Python') {
            steps {
                sh '''
                    python3 -V || sudo apt-get update && sudo apt-get install -y python3.11 python3.11-venv python3-pip
                    python3.11 -m venv venv
                    . venv/bin/activate
                    pip install --upgrade pip
                '''
            }
        }
        
        stage('Install Dependencies') {
            steps {
                sh '''
                    . venv/bin/activate
                    pip install -r requirements.txt
                '''
            }
        }
        
        stage('Lint & Security Check') {
            steps {
                sh '''
                    . venv/bin/activate
                    pip install flake8 bandit
                    flake8 . --exclude=venv,migrations --max-line-length=120
                    bandit -r . --exclude venv,migrations
                '''
            }
        }
        
        stage('Run Tests') {
            steps {
                sh '''
                    . venv/bin/activate
                    pip install coverage
                    coverage run manage.py test
                    coverage report --fail-under=80
                    coverage html
                    coverage xml
                '''
            }
        }
        
        stage('Database Checks') {
            steps {
                sh '''
                    . venv/bin/activate
                    python manage.py check --deploy
                    python manage.py makemigrations --dry-run --check
                '''
            }
        }
        
        stage('Build & Push Docker Image') {
            steps {
                sh '''
                    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                    docker build -t $IMAGE_NAME:$IMAGE_TAG .
                    docker push $IMAGE_NAME:$IMAGE_TAG
                    docker tag $IMAGE_NAME:$IMAGE_TAG $IMAGE_NAME:latest
                    docker push $IMAGE_NAME:latest
                '''
            }
        }
        
        stage('Deploy to Staging') {
            when { branch 'main' }
            steps {
                sh '''
                    docker stop pharmacy-app || true
                    docker rm pharmacy-app || true
                    docker run -d \
                        --name pharmacy-app \
                        -p 8000:8000 \
                        -e DATABASE_URL=${DATABASE_URL} \
                        -e SECRET_KEY=${SECRET_KEY} \
                        --restart always \
                        $IMAGE_NAME:$IMAGE_TAG
                '''
            }
        }
    }
    
    post {
        always {
            sh '''
                docker logout || true
                . venv/bin/activate || true
                deactivate || true
                rm -rf venv htmlcov .coverage coverage.xml
            '''
            cleanWs()
        }
        success {
            echo "✅ Pharmacy Management ${BUILD_NUMBER} deployed! http://your-server:8000"
        }
        failure {
            echo "❌ Build ${BUILD_NUMBER} failed!"
        }
    }
}
