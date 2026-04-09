pipeline {
    agent any

    environment {
        JAVA_HOME = tool name: 'Java21', type: 'jdk'
        MAVEN_HOME = tool name: 'Maven', type: 'maven'
        PATH = "${env.JAVA_HOME}/bin:${env.MAVEN_HOME}/bin:${env.PATH}"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout([$class: 'GitSCM',
                    branches: [[name: 'Develop']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/jeevana1409/Application-Repo.git',
                        credentialsId: 'github-tokens'
                    ]]
                ])
            }
        }

        stage('Auto Version Increment') {
            steps {
                script {
                    sh 'git config --global --add safe.directory "*"'
                    sh 'git fetch --tags'
                    def latestTag = sh(script: "git tag --sort=-v:refname | head -n 1", returnStdout: true).trim()
                    echo "Latest Tag: ${latestTag}"

                    def (major, minor, patch) = latestTag.replace('v','').tokenize('.').collect { it.toInteger() }
                    patch += 1
                    env.NEW_VERSION = "v${major}.${minor}.${patch}"
                    echo "New Version: ${env.NEW_VERSION}"

                    withCredentials([usernamePassword(credentialsId: 'github-tokens', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASSWORD')]) {
                        sh """
                            git config user.name jenkins
                            git config user.email jenkins@local
                            git tag ${env.NEW_VERSION}
                            git push https://${GIT_USER}:${GIT_PASSWORD}@github.com/jeevana1409/Application-Repo.git ${env.NEW_VERSION}
                        """
                    }
                }
            }
        }

        stage('Update Maven Version') {
            steps {
                sh "mvn versions:set -DnewVersion=${env.NEW_VERSION} -DgenerateBackupPoms=false"
            }
        }

        stage('Build WAR') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Security Scan') {
            steps {
                echo 'Running security scan... (replace with actual tool)'
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    def imageName = "jeevana1409/application-repo:${env.NEW_VERSION}"
                    sh "docker build -t ${imageName} ."
                    sh "docker push ${imageName}"
                    echo "Docker image pushed: ${imageName}"
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline succeeded!'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}
