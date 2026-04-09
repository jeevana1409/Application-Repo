pipeline {
    agent any

    tools {
        maven 'Maven'
        jdk 'jdk21'
    }

    environment {
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
                script {
                    def javaHome = tool 'jdk21'
                    withEnv(["JAVA_HOME=${javaHome}", "PATH=${javaHome}/bin:${env.PATH}"]) {
                        sh 'java -version'
                        sh 'mvn -version'
                    }
                }
            }
        }

        stage('Update Maven Version') {
            steps {
                script {
                    def javaHome = tool 'jdk21'
                    withEnv(["JAVA_HOME=${javaHome}", "PATH=${javaHome}/bin:${env.PATH}"]) {
                        sh "mvn versions:set -DnewVersion=${APP_VERSION} -DgenerateBackupPoms=false"
                    }
                }
            }
        }

        stage('Build & Package') {
            steps {
                script {
                    def javaHome = tool 'jdk21'
                    withEnv(["JAVA_HOME=${javaHome}", "PATH=${javaHome}/bin:${env.PATH}"]) {
                        sh "mvn clean package -DskipTests"
                    }
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    def javaHome = tool 'jdk21'
                    withEnv(["JAVA_HOME=${javaHome}", "PATH=${javaHome}/bin:${env.PATH}"]) {
                        sh "mvn test"
                    }
                }
            }
        }

        stage('Deploy to Nexus') {
            steps {
                script {
                    def javaHome = tool 'jdk21'
                    withEnv(["JAVA_HOME=${javaHome}", "PATH=${javaHome}/bin:${env.PATH}"]) {
                        sh "mvn deploy -DskipTests"
                    }
                }
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
                        sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker build -t ${DOCKER_IMAGE}:${APP_VERSION} -f webapp/Dockerfile .
                        docker push ${DOCKER_IMAGE}:${APP_VERSION}
                        docker logout
                        '''
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
