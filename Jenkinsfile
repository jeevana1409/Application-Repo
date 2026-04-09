pipeline {
    agent any

    tools {
        maven 'Maven'      // must match Jenkins Global Tool Configuration
        jdk 'Java21'       // add if your build needs Java
    }

    environment {
        DOCKER_IMAGE = "sony9014/myapp"
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
                    sh '''
                    git config --global --add safe.directory '*'
                    git fetch --tags
                    '''

                    // Get latest tag (or default)
                    def latestTag = sh(
                        script: "git tag --sort=-v:refname | head -n 1 || echo v1.0.0",
                        returnStdout: true
                    ).trim()

                    echo "Latest Tag: ${latestTag}"

                    def version = latestTag.replace("v","").tokenize('.')
                    def major = version[0]
                    def minor = version[1]
                    def patch = version[2].toInteger() + 1

                    env.APP_VERSION = "v${major}.${minor}.${patch}"
                    echo "New Version: ${env.APP_VERSION}"

                    withCredentials([usernamePassword(
                        credentialsId: 'github-cred',
                        usernameVariable: 'GIT_USERNAME',
                        passwordVariable: 'GIT_PASSWORD'
                    )]) {
                        sh '''
                        git config user.name "jenkins"
                        git config user.email "jenkins@local"
                        '''

                        def tagExists = sh(
                            script: "git tag -l ${APP_VERSION}",
                            returnStdout: true
                        ).trim()

                        if (!tagExists) {
                            sh "git tag ${APP_VERSION}"
                            sh "git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/jeevana1409/App-Repo.git ${APP_VERSION}"
                        } else {
                            echo "⚠️ Tag already exists, skipping..."
                        }
                    }
                }
            }
        }

        stage('Update Maven Version') {
            steps {
                sh "mvn versions:set -DnewVersion=${APP_VERSION}"
            }
        }

        stage('Build WAR') {
            steps {
                sh "mvn clean package -DskipTests"
            }
        }

        stage('Run Tests') {
            steps {
                sh "mvn test"
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
                        docker build -t ${DOCKER_IMAGE}:${APP_VERSION} .
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
