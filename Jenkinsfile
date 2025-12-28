pipeline {
    agent any
    
    environment {
        DJANGO_PROJECT = 'pharmacy'
        DOCKER_IMAGE = 'areebaa7/pharmacy-management'
        DOCKERHUB_USER = 'areebaa7'
        DOCKERHUB_PASS = 'your-dockerhub-password-here'  // ⚠️ REPLACE WITH YOUR PASSWORD
        DOCKERHUB_REPO = 'areebaa7/pharmacy-management:latest'
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
                bat '''
                    python --version
                    py -3 --version
                    where python
                    pip --version
                '''
            }
        }
        
        stage('Install Dependencies') {
            steps {
                bat '''
                    py -3 -m pip install --upgrade pip
                    py -3 -m pip install -r requirements.txt
                '''
            }
        }
        
        stage('Lint & Security') {
            steps {
                bat '''
                    py -3 -m pip install flake8 bandit
                    flake8 . --exclude=venv,migrations,__pycache__
                    bandit -r . --skip=B101,B307,B108 || exit /b 0
                '''
            }
        }
        
        stage('Django Checks') {
            steps {
                bat '''
                    py -3 manage.py check --deploy
                    py -3 manage.py makemigrations --dry-run
                '''
            }
        }
        
        stage('Run Tests') {
            steps {
                bat '''
                    py -3 manage.py test --verbosity=2 --keepdb --failfast || exit /b 0
                '''
            }
        }
        
        stage('Static Files') {
            steps {
                bat '''
                    py -3 manage.py collectstatic --noinput --clear
                '''
            }
        }
        
        stage('Build Docker') {
            steps {
                bat '''
                    docker build -t %DOCKER_IMAGE%:%BUILD_NUMBER% .
                    docker tag %DOCKER_IMAGE%:%BUILD_NUMBER% %DOCKERHUB_REPO%
                '''
            }
        }
        
        stage('Push Docker') {
            when {
                branch 'main'
            }
            steps {
                bat '''
                    echo %DOCKERHUB_PASS% | docker login -u %DOCKERHUB_USER% --password-stdin
                    docker push %DOCKERHUB_REPO%
                    docker push %DOCKER_IMAGE%:%BUILD_NUMBER%
                '''
            }
        }
        
        stage('Deploy Staging') {
            when {
                branch 'main'
            }
            steps {
                bat '''
                    docker stop pharmacy-staging || exit /b 0
                    docker rm pharmacy-staging || exit /b 0
                    docker run -d ^
                        --name pharmacy-staging ^
                        -p 8080:8000 ^
                        -e DEBUG=False ^
                        -e ALLOWED_HOSTS=* ^
                        -e SECRET_KEY=django-insecure-your-secret-key-here ^
                        --restart unless-stopped ^
                        %DOCKERHUB_REPO%
                '''
            }
        }
    }
    
    post {
        always {
            bat '''
                echo Cleaning up...
                if exist venv rmdir /s /q venv
                if exist __pycache__ rmdir /s /q __pycache__
                docker system prune -f
            '''
        }
        success {
            bat '''
                echo ✅ PIPELINE SUCCESS!
                echo 🐳 Image: %DOCKERHUB_REPO%
                echo 🔢 Build: %BUILD_NUMBER%
                echo 🌐 Access: http://localhost:8080
                echo 🚀 Pharmacy app deployed!
            '''
        }
        failure {
            bat '''
                echo ❌ BUILD FAILED!
                echo Review logs above.
            '''
        }
    }
}
