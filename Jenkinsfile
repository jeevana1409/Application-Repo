pipeline {
    agent any

    environment {
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk' // Path to JDK on your Jenkins node
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
    }

    tools {
        maven 'Maven 3.9' // Use the name of Maven in Global Tool Configuration
    }

    stages {

        stage('Checkout SCM') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/Develop']],
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
                    
                    def newVersion = latestTag ? latestTag.tokenize('v')[1].split('\\.').collect{it as int}.with { [it[0], it[1], it[2]+1].join('.') } : "0.0.1"
                    echo "New Version: v${newVersion}"

                    withCredentials([string(credentialsId: 'github-tokens', variable: 'GIT_PASSWORD')]) {
                        sh "git config user.name jenkins"
                        sh "git config user.email jenkins@local"
                        sh "git tag -l v${newVersion} || git tag v${newVersion}"
                        sh "git push https://jeevana1409:${GIT_PASSWORD}@github.com/jeevana1409/Application-Repo.git v${newVersion}"
                    }
                }
            }
        }

        stage('Update Maven Version') {
            steps {
                sh "mvn versions:set -DnewVersion=v${newVersion}"
            }
        }

        stage('Build WAR') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Security Scan') {
            steps {
                echo "Placeholder for security scan"
            }
        }

        stage('Docker Build & Push') {
            steps {
                echo "Placeholder for Docker build and push"
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline Succeeded"
        }
        failure {
            echo "❌ Pipeline Failed"
        }
    }
}
