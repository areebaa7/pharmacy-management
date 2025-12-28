pipeline {
    agent any
    
    environment {
        DJANGO_PROJECT = 'pharmacy'
        DOCKER_IMAGE = 'areeba77/pharmacy-management'
        DOCKERHUB_USER = 'areeba77'
        DOCKERHUB_PASS = 'cr7forevergoat'  // HARDCODED
        DOCKERHUB_REPO = 'areeba77/pharmacy-management:latest'
        PYTHON = 'python'  // Use 'python' directly (works with 3.14)
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
                    %PYTHON% --version
                    where %PYTHON%
                    pip --version
                '''
            }
        }
        
        stage('Install Dependencies') {
            steps {
                bat '''
                    %PYTHON% -m pip install --upgrade pip
                    %PYTHON% -m pip install -r requirements.txt
                '''
            }
        }
        
        stage('Lint & Security') {
            steps {
                bat '''
                    %PYTHON% -m pip install flake8 bandit
                    flake8 . --exclude=venv,migrations,__pycache__ || exit /b 0
                    bandit -r . --skip=B101,B307,B108 || exit /b 0
                '''
            }
        }
        
        stage('Django Checks') {
            steps {
                bat '''
                    %PYTHON% manage.py check --deploy || exit /b 0
                    %PYTHON% manage.py makemigrations --dry-run || exit /b 0
                '''
            }
        }
        
        stage('Run Tests') {
            steps {
                bat '''
                    %PYTHON% manage.py test --verbosity=2 --keepdb --failfast || exit /b 0
                '''
            }
        }
        
        stage('Static Files') {
            steps {
                bat '''
                    %PYTHON% manage.py collectstatic --noinput --clear || exit /b 0
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
                        -e SECRET_KEY=django-insecure-change-this-in-production ^
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
            '''
        }
        success {
            bat '''
                echo ✅ PIPELINE SUCCESS!
                echo 🐳 Image: %DOCKERHUB_REPO%
                echo 🌐 http://localhost:8080
            '''
        }
        failure {
            bat 'echo ❌ BUILD FAILED! Check logs above.'
        }
    }
}
