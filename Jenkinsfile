pipeline {
    agent any

    tools {
        maven 'Maven'
    }

    environment {
        JAVA_HOME = "/usr/lib/jvm/java-21-amazon-corretto.x86_64"
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
        DOCKER_IMAGE = "jeevan204/myapp"
    }

    stages {

        stage('Auto Version Increment') {
            steps {
                script {
                    sh 'git fetch --tags'

                    def latestTag = sh(
                        script: "git describe --tags \$(git rev-list --tags --max-count=1) 2>/dev/null || echo v1.0.0",
                        returnStdout: true
                    ).trim()

                    echo "Latest Tag: ${latestTag}"

                    def version = latestTag.replace("v","").tokenize('.')
                    def major = version[0]
                    def minor = version[1]
                    def patch = version[2].toInteger()

                    def newTag = ""
                    def tagExists = true

                    while(tagExists) {
                        patch++
                        newTag = "v${major}.${minor}.${patch}"

                        def status = sh(
                            script: "git rev-parse ${newTag} >/dev/null 2>&1 || echo 'notfound'",
                            returnStdout: true
                        ).trim()

                        if (status == "notfound") {
                            tagExists = false
                        }
                    }

                    env.APP_VERSION = newTag
                    echo "New Version: ${APP_VERSION}"

                    withCredentials([usernamePassword(
                        credentialsId: 'github-tokens',
                        usernameVariable: 'GIT_USERNAME',
                        passwordVariable: 'GIT_PASSWORD'
                    )]) {
                        sh '''
                        git config user.name "jenkins"
                        git config user.email "jenkins@local"
                        git tag ${APP_VERSION}
                        git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/jeevana1409/Application-Repo.git ${APP_VERSION}
                        '''
                    }
                }
            }
        }

        stage('Verify Java & Maven') {
            steps {
                sh 'java -version'
                sh 'mvn -version'
            }
        }

        stage('Update Maven Version') {
            steps {
                sh "mvn versions:set -DnewVersion=${APP_VERSION} -DgenerateBackupPoms=false"
            }
        }

        stage('Build & Package') {
            steps {
                sh "mvn clean package -DskipTests"
            }
        }

        stage('Run Tests') {
            steps {
                sh "mvn test"
            }
        }

        stage('Deploy to Nexus') {
            steps {
                sh "mvn deploy -DskipTests"
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
                        credentialsId: 'docker-cred',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker build -t ${DOCKER_IMAGE}:${APP_VERSION} -f Dockerfile .
                        docker push ${DOCKER_IMAGE}:${APP_VERSION}
                        docker logout
                        '''
                    }
                }
            }
        }

        stage('Trigger Deployment Repo') {
            steps {
                build job: 'deployment-repo-job-name',
                parameters: [
                    string(name: 'BRANCH_NAME', value: 'dev'),
                    string(name: 'APP_VERSION', value: "${APP_VERSION}")
                ]
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
