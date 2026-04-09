pipeline {
    agent any
    
    environment {
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk' // Path to JDK
        PATH = "${JAVA_HOME}/bin:${env.PATH}"      // Ensure Java binaries are available
    }
    
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
                    sh '''
                        git config --global --add safe.directory '*'
                        git fetch --tags
                    '''

                    // Get latest tag, default to v0.0.0 if none exist
                    def latestTag = sh(
                        script: "git tag --sort=-v:refname | head -n 1 || echo v0.0.0",
                        returnStdout: true
                    ).trim()

                    echo "Latest Tag: ${latestTag}"

                    // Extract version numbers safely
                    def version = latestTag.replace("v","").tokenize('.')
                    def major = version[0] ?: '0'
                    def minor = version[1] ?: '0'
                    def patch = (version.size() > 2 ? version[2].toInteger() : 0) + 1

                    env.APP_VERSION = "v${major}.${minor}.${patch}"
                    echo "New Version: ${env.APP_VERSION}"

                    withCredentials([usernamePassword(
                        credentialsId: 'github-tokens',
                        usernameVariable: 'GIT_USERNAME',
                        passwordVariable: 'GIT_PASSWORD'
                    )]) {

                        sh '''
                            git config user.name "jenkins"
                            git config user.email "jenkins@local"
                        '''

                        // Check if tag already exists
                        def tagExists = sh(
                            script: "git tag -l ${env.APP_VERSION}",
                            returnStdout: true
                        ).trim()

                        if (tagExists) {
                            echo "⚠️ Tag already exists. Skipping tag creation..."
                        } else {
                            sh """
                                git tag ${APP_VERSION}
                                git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/jeevana1409/App-Repo.git ${APP_VERSION}
                            """
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
