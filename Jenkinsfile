pipeline {
    agent any

    tools {
        maven 'maven'
        jdk 'jdk21'
    }

    stages {

        stage('Build & Test') {
            steps {
                sh "mvn clean verify"
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh "mvn sonar:sonar"
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
                not {
                    branch 'dev'
                }
            }
            steps {
                script {
                    def branchName = env.BRANCH_NAME
                    echo "Creating PR from ${branchName} to dev"

                    withCredentials([string(credentialsId: 'github-api-creds', variable: 'GITHUB_TOKEN')]) {
                        sh """
                        curl -X POST https://api.github.com/repos/jeevana1409/Application-Repo/pulls \
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
