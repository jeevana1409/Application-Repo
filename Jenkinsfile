pipeline {
    agent any

    environment {
        NEXUS_URL = "http://<NEXUS_URL>:8081"
        NEXUS_REPO = "maven-releases"
        GROUP_ID = "com.mycompany.app"
        ARTIFACT_ID = "my-app"
        VERSION = "${env.BUILD_TAG}"   // or pass from release pipeline
        DEPLOYMENT_REPO = "git@github.com:your-org/deployment-repo.git"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'git@github.com:your-org/application-repo.git'
            }
        }

        stage('Validate Artifact in Nexus') {
            steps {
                script {
                    def artifactUrl = "${NEXUS_URL}/repository/${NEXUS_REPO}/" +
                                      "${GROUP_ID.replace('.', '/')}/${ARTIFACT_ID}/${VERSION}/${ARTIFACT_ID}-${VERSION}.jar"

                    echo "Checking artifact at: ${artifactUrl}"

                    def response = sh(
                        script: "curl -o /dev/null -s -w \"%{http_code}\" ${artifactUrl}",
                        returnStdout: true
                    ).trim()

                    if (response != "200") {
                        error "❌ Artifact NOT found in Nexus. Aborting deployment."
                    } else {
                        echo "✅ Artifact exists in Nexus."
                    }
                }
            }
        }

        stage('Trigger Deployment Pipeline') {
            steps {
                build job: 'deployment-repo-pipeline',
                parameters: [
                    string(name: 'ARTIFACT_ID', value: "${ARTIFACT_ID}"),
                    string(name: 'VERSION', value: "${VERSION}"),
                    string(name: 'ENV', value: "dev")   // initial env
                ],
                wait: false
            }
        }
    }

    post {
        success {
            echo "✅ Main branch pipeline completed. Deployment triggered."
        }
        failure {
            echo "❌ Pipeline failed. Check logs."
        }
    }
}
