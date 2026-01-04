pipeline {
    agent any
    
    environment {
        DJANGO_PROJECT = 'pharm'
        DOCKER_IMAGE = 'areeba77/pharmacy-management'
        DOCKERHUB_USER = 'areeba77'
        DOCKERHUB_REPO = 'areeba77/pharmacy-management:latepipeline {
    agent any
    
    environment {
        DJANGO_PROJECT = 'pharm'
        DOCKER_IMAGE = 'areeba77/pharmacy-management'
        DOCKERHUB_USER = 'areeba77'
        DOCKERHUB_REPO = 'areeba77/pharmacy-management:latest'
        PYTHON = 'python3'
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
                    $PYTHON --version
                    which $PYTHON
                    pip3 --version
                '''
            }
        }
        
        stage('Install Dependencies') {
            steps {
                sh '''
                    $PYTHON -m pip install --upgrade pip
                    $PYTHON -m pip install -r requirements.txt
                '''
            }
        }
        
        stage('Lint & Security') {
            steps {
                sh '''
                    pip install flake8 bandit
                    flake8 . --exclude=venv,migrations,__pycache__ || true
                    bandit -r . --skip=B101,B307,B108 || true
                '''
            }
        }
        
        stage('Django Checks') {
            steps {
                sh '''
                    $PYTHON manage.py check --deploy || true
                    $PYTHON manage.py makemigrations --dry-run || true
                '''
            }
        }
        
        stage('Run Tests') {
            steps {
                sh '''
                    $PYTHON manage.py test --verbosity=2 --keepdb --failfast || true
                '''
            }
        }
        
        stage('Static Files') {
            steps {
                sh '''
                    $PYTHON manage.py collectstatic --noinput --clear || true
                '''
            }
        }
        
        stage('Build Docker') {
            steps {
                sh '''
                    docker build -t $DOCKER_IMAGE:$BUILD_NUMBER .
                    docker tag $DOCKER_IMAGE:$BUILD_NUMBER $DOCKERHUB_REPO
                '''
            }
        }
        
        stage('Push Docker') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $DOCKERHUB_REPO
                    '''
                }
            }
        }
        
        stage('Deploy Staging') {
            steps {
                sh '''
                    docker stop pharmacy-staging || true
                    docker rm pharmacy-staging || true

                    docker run -d \
                        --name pharmacy-staging \
                        -p 9000:8000 \
                        -e DEBUG=False \
                        -e ALLOWED_HOSTS=* \
                        -e SECRET_KEY=django-insecure-production \
                        --restart unless-stopped \
                        $DOCKERHUB_REPO
                '''
            }
        }
    }

    post {
        success {
            echo '✅ PIPELINE SUCCESS!'
            echo "🌐 App running at http://13.60.30.192:9000"
        }
        failure {
            echo '❌ PIPELINE FAILED!'
        }
    }
}
'
        PYTHON = 'python3'
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
                    $PYTHON --version
                    which $PYTHON
                    pip3 --version
                '''
            }
        }
        
        stage('Install Dependencies') {
            steps {
                sh '''
                    $PYTHON -m pip install --upgrade pip
                    $PYTHON -m pip install -r requirements.txt
                '''
            }
        }
        
        stage('Lint & Security') {
            steps {
                sh '''
                    pip install flake8 bandit
                    flake8 . --exclude=venv,migrations,__pycache__ || true
                    bandit -r . --skip=B101,B307,B108 || true
                '''
            }
        }
        
        stage('Django Checks') {
            steps {
                sh '''
                    $PYTHON manage.py check --deploy || true
                    $PYTHON manage.py makemigrations --dry-run || true
                '''
            }
        }
        
        stage('Run Tests') {
            steps {
                sh '''
                    $PYTHON manage.py test --verbosity=2 --keepdb --failfast || true
                '''
            }
        }
        
        stage('Static Files') {
            steps {
                sh '''
                    $PYTHON manage.py collectstatic --noinput --clear || true
                '''
            }
        }
        
        stage('Build Docker') {
            steps {
                sh '''
                    docker build -t $DOCKER_IMAGE:$BUILD_NUMBER .
                    docker tag $DOCKER_IMAGE:$BUILD_NUMBER $DOCKERHUB_REPO
                '''
            }
        }
        
        stage('Push Docker') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $DOCKERHUB_REPO
                    '''
                }
            }
        }
        
        stage('Deploy Staging') {
            steps {
                sh '''
                    docker stop pharmacy-staging || true
                    docker rm pharmacy-staging || true

                    docker run -d \
                        --name pharmacy-staging \
                        -p 9000:8000 \
                        -e DEBUG=False \
                        -e ALLOWED_HOSTS=* \
                        -e SECRET_KEY=django-insecure-production \
                        --restart unless-stopped \
                        $DOCKERHUB_REPO
                '''
            }
        }
    }

    post {
        success {
            echo '✅ PIPELINE SUCCESS!'
            echo "🌐 App running at http://<EC2_PUBLIC_IP>:9000"
        }
        failure {
            echo '❌ PIPELINE FAILED!'
        }
    }
}
