pipeline {
    agent any

    tools {
        maven 'Maven'
        jdk 'Java21'
    }

    environment {
        DOCKER_IMAGE = "jeevan204/myapp"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Auto Version Increment') {
            steps {
                script {
                    sh 'git fetch --tags'

                    def latestTag = sh(
                        script: "git describe --tags \$(git rev-list --tags --max-count=1) 2>/dev/null || echo v1.0.0",
                        returnStdout: true
                    ).trim()

                    echo "Latest Tag: ${latestTag}"

                    def version = latestTag.replace("v","").tokenize('.')
                    def major = version[0]
                    def minor = version[1]
                    def patch = version[2].toInteger() + 1

                    env.APP_VERSION = "v${major}.${minor}.${patch}"
                    echo "New Version: ${APP_VERSION}"

                    withCredentials([usernamePassword(
                        credentialsId: 'github-tokens',
                        usernameVariable: 'GIT_USERNAME',
                        passwordVariable: 'GIT_PASSWORD'
                    )]) {
                        sh """
                        git config user.name "jenkins"
                        git config user.email "jenkins@local"
                        git tag ${APP_VERSION}
                        git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/jeevana1409/Application-Repo.git ${APP_VERSION}
                        """
                    }
                }
            }
        }

        stage('Update Maven Version') {
            steps {
                // Update version for all modules
                sh "mvn versions:set -DnewVersion=${APP_VERSION} -DgenerateBackupPoms=false"
            }
        }

        stage('Build & Package') {
            steps {
                // Clean build for entire multi-module project
                sh "mvn clean package -DskipTests"
            }
        }

        stage('Run Tests') {
            steps {
                // Run all tests in multi-module project
                sh "mvn test"
            }
        }

        stage('Deploy to Nexus') {
            steps {
                // Deploy all modules to Nexus
                sh "mvn deploy -DskipTests"
            }
        }

        stage('Security Scan') {
            steps {                                      
                sh "trivy fs --severity HIGH,CRITICAL --exit-code 1 ."
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh """
                        echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                        
                        # Build Docker image from webapp WAR
                        docker build -t ${DOCKER_IMAGE}:${APP_VERSION} -f webapp/Dockerfile .
                        
                        docker push ${DOCKER_IMAGE}:${APP_VERSION}
                        docker logout
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline Completed Successfully"
        }
        failure {
            echo "❌ Pipeline Failed"
        }
    }
}
