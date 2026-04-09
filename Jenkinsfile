pipeline {
    agent any

    environment {
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk'
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
    }

    tools {
        maven 'Maven' // Use the exact name of your Maven installation in Jenkins Global Tool Configuration
    }

    stages {

        stage('Checkout SCM') {
            steps {
                checkout([$class: 'GitSCM',
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
                    def latestTag = sh(script: "git tag --sort=-v:refname | head -n 1", returnStdout: true).trim()
                    echo "Latest Tag: ${latestTag}"
                    def newVersion = latestTag ? "v${latestTag.tokenize('v')[1].toInteger() + 1}" : "v0.0.1"
                    echo "New Version: ${newVersion}"

                    withCredentials([string(credentialsId: 'github-tokens', variable: 'GIT_PASSWORD')]) {
                        sh """
                            git config user.name jenkins
                            git config user.email jenkins@local
                            git tag -a ${newVersion} -m 'Auto increment'
                            git push https://jeevana1409:${GIT_PASSWORD}@github.com/jeevana1409/Application-Repo.git ${newVersion}
                        """
                    }
                    env.NEW_VERSION = newVersion
                }
            }
        }

        stage('Update Maven Version') {
            steps {
                sh "mvn versions:set -DnewVersion=${env.NEW_VERSION}"
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
                echo 'Security scan placeholder'
            }
        }

        stage('Docker Build & Push') {
            steps {
                echo 'Docker build & push placeholder'
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline Succeeded!"
        }
        failure {
            echo "❌ Pipeline Failed!"
        }
    }
}
