pipeline {
    agent any

    environment {
        JAVA_HOME = tool name: 'jdk21', type: 'jdk'
        PATH = "${env.JAVA_HOME}/bin:${env.PATH}"
    }

    stages {

        stage('Checkout SCM') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: 'Develop']],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [],
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
                    
                    // Get latest tag
                    def latestTag = sh(script: "git tag --sort=-v:refname | head -n 1", returnStdout: true).trim()
                    echo "Latest Tag: ${latestTag}"

                    def newVersion = "v0.0.1" // default if no tag exists
                    if (latestTag) {
                        def parts = latestTag.replace("v","").tokenize('.') // ["0","0","5"]
                        def major = parts[0].toInteger()
                        def minor = parts[1].toInteger()
                        def patch = parts[2].toInteger() + 1 // increment patch
                        newVersion = "v${major}.${minor}.${patch}"
                    }

                    echo "New Version: ${newVersion}"
                    env.NEW_VERSION = newVersion

                    withCredentials([string(credentialsId: 'github-tokens', variable: 'GIT_PASSWORD')]) {
                        sh """
                            git config user.name jenkins
                            git config user.email jenkins@local
                            git tag -a ${newVersion} -m 'Auto increment'
                            git push https://jeevana1409:${GIT_PASSWORD}@github.com/jeevana1409/Application-Repo.git ${newVersion}
                        """
                    }
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
                sh "mvn clean package"
            }
        }

        stage('Run Tests') {
            steps {
                sh "mvn test"
            }
        }

        stage('Security Scan') {
            steps {
                // Example: run a security tool like OWASP Dependency Check
                sh "echo 'Security scan stage - implement your scanner here'"
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    def dockerImage = "jeevana1409/app:${env.NEW_VERSION}"
                    sh "docker build -t ${dockerImage} ."
                    sh "docker push ${dockerImage}"
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline Succeeded with version ${env.NEW_VERSION}"
        }
        failure {
            echo "❌ Pipeline Failed"
        }
    }
}
