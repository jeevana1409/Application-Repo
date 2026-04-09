pipeline {
    agent any

    tools {
        maven 'Maven'
        jdk 'Java21'
    }

    environment {
        JAVA_HOME = tool 'Java21'
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                sh """
                java -version
                mvn -version
                mvn clean verify
                """
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh """
                    mvn sonar:sonar \
                      -Dsonar.projectKey=ebhook \
                      -Dsonar.projectName=ebhook
                    """
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 3, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Create Pull Request to Dev') {
            when {
                allOf {
                    not { branch 'dev' }
                    not { branch 'main' }
                }
            }
            steps {
                script {
                    def branchName = env.BRANCH_NAME
                    echo "Creating PR from ${branchName} to dev"

                    withCredentials([string(credentialsId: 'github-cred', variable: 'GITHUB_TOKEN')]) {
                        sh """
                        curl -s -o response.json -w "%{http_code}" \
                        -X POST https://api.github.com/repos/jeevana1409/Application-Repo/pulls \
                        -H "Authorization: token \$GITHUB_TOKEN" \
                        -H "Accept: application/vnd.github+json" \
                        -d '{
                          "title": "Auto PR: ${branchName} → dev",
                          "head": "${branchName}",
                          "base": "dev",
                          "body": "Created automatically by Jenkins."
                        }'
                        """
                    }
                }
            }
        }

    }

    post {
        success {
            echo "✅ Pipeline completed successfully"
        }
        failure {
            echo "❌ Pipeline failed"
        }
    }
}
