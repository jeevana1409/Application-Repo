pipeline {
    agent any

    environment {
        JAVA_HOME = tool name: 'Java21', type: 'jdk'
        PATH = "${env.JAVA_HOME}/bin:${env.PATH}"
        MAVEN_HOME = tool name: 'Maven', type: 'maven'
        PATH = "${MAVEN_HOME}/bin:${env.PATH}"
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
                    // Get latest tag
                    def latestTag = sh(script: "git tag --sort=-v:refname | head -n 1", returnStdout: true).trim()
                    echo "Latest Tag: ${latestTag}"

                    // Extract version numbers
                    def (major, minor, patch) = latestTag.replace('v', '').tokenize('.').collect { it.toInteger() }

                    // Increment patch version
                    patch += 1
                    env.NEW_VERSION = "v${major}.${minor}.${patch}"
                    echo "New Version: ${env.NEW_VERSION}"

                    // Create git tag
                    sh "git tag ${env.NEW_VERSION}"
                    sh "git push origin ${env.NEW_VERSION}"
                }
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
                echo 'Running security scan...' 
                // Example: add your actual security scan tool here
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
