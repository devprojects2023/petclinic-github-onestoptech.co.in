//**********************************************************************************************************************************\\

pipeline {
    agent any

    tools {
        maven 'mvn'
        jdk 'jdk:17'
    }

    environment {
        scannerHome = tool 'sonar-tool'     // need to change your sonar tool name
        DOCKER_HUB_REPO = 'devhdocker'      // need to change your dockerhub repository
        DOCKER_HUB_CREDENTIALS = 'docker'   // need to change your docker credential in the Jenkins credentials
        IMAGE_NAME = 'petclinic-demo'       // need to change the image name as per your needs 
        TAG_NAME = 'v2'                     // need to change the tag if needed
        KUBE_MANIFESTS_FOLDER = 'k8s/deploy'
    }
    stages {
        stage('git checkout') {
            steps {
                // git branch: 'main', credentialsId: 'Git-Credential', url: ''   // use this for private repo
                git branch: 'main', url: 'https://github.com/devprojects2023/petclinic-github-onestoptech.co.in.git'
                }
        }
        stage("Compile"){
            steps{
                sh "mvn clean compile -DskipTests -Dcheckstyle.skip"
            }
        }

        stage("Unit Test"){
            steps{
                sh "mvn test -DskipTests -Dcheckstyle.skip"
            }
        }

        stage('sonarqube analisis') {
            steps {
                withSonarQubeEnv('sonar-api') {
                    sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectName=Java -Dsonar.projectKey=Java -Dsonar.java.binaries=."
                  
                }
            }
        }

        stage("Quality Gate") {    // need to creta quality gate requirment for the code in sonarqube and save that as default.
            steps {
              timeout(time: 1, unit: 'HOURS') {
                waitForQualityGate abortPipeline: true
              }
            }
        }

        stage('dependency check') {  // you can add more arguments as per your needs. https://jeremylong.github.io/DependencyCheck/index.html
            steps {
                dependencyCheck additionalArguments: '--scan ./ --format XML --out ./', odcInstallation: 'dependency-check'
                    dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
                }
        }

        // Uncomment Maven stages if needed
        stage('maven install') {
            steps {
                sh "mvn clean install -DskipTests -Dcheckstyle.skip"
                // sh "mvn clean install -Dcheckstyle.skip"
            }
        }
        

        stage('Docker-build & tag the image') {
            steps { 
                sh 'yes | docker system prune -a --volumes'
                sh "docker build -t $DOCKER_HUB_REPO/$IMAGE_NAME:$TAG_NAME ."
                sh "docker tag $DOCKER_HUB_REPO/$IMAGE_NAME:$TAG_NAME $DOCKER_HUB_REPO/$IMAGE_NAME:$TAG_NAME"      
                }    
        }

        stage('Push to Docker-hub Registry') {
            steps {
                script {
                    // This step should not normally be used in your script. Pipeline syntax step name: "withDockerRegistry: Sets up Docker registry endpoint"
                    withDockerRegistry(credentialsId: 'docker', toolName: 'docker') {
                        // Push the Docker image to Docker Hub repo
                        sh "docker push $DOCKER_HUB_REPO/$IMAGE_NAME:$TAG_NAME"
                        } 
                }
            }
        }
        stage('trivy'){   // it will scan the image.
            steps{
                sh "trivy image --severity HIGH,CRITICAL $DOCKER_HUB_REPO/$IMAGE_NAME:$TAG_NAME" 
            }
        }

        // withKubeConfig:Configure Kubernetes CLI (kubectl)
        stage('deploy to kubernetes cluster') {
            steps {
                script {
                    dir(env.KUBE_MANIFESTS_FOLDER) {
                        // Use the specified Kubernetes configuration
                        withKubeConfig(
                            credentialsId: '19a91579-3954-4abb-8bab-17a93f5e3711'  // Specify Jenkins credentials ID
                        ) {
                            // Apply all YAML files in the folder
                            sh 'kubectl cluster-info'
                            sh 'kubectl delete deploy webapp-depl -n dev-pet'
                            sh 'pwd'
                            sh 'ls -lart'
                            sh 'kubectl get pods -n=dev-pet'
                            sh 'kubectl get all --all-namespaces'
                            sh 'kubectl apply -f .'
                        }
                    }

                }
            }
        }
    }

        post{
            success {
                emailext attachLog: true, attachmentsPattern: '.zip', body: """'This is to inform you that the Project: ${env.JOB_NAME} has been successed.<br/> Here is the Build Number: ${env.BUILD_NUMBER} for your reference.<br/> You can get the details from this URL: ${env.BUILD_URL} and also I have attached the build cosole log, please take a look. Thanks.'""", compressLog: true, mimeType: 'text/html', recipientProviders: [buildUser()], replyTo: 'devpay2022@gmail.com', subject: "'This is the Build Status of last Jenkins job: ${currentBuild.result}'", to: 'devpay2022@gmail.com'
                
                // mail bcc: '', body: """'Project: ${env.JOB_NAME}<br/> Build Number: ${env.BUILD_NUMBER}<br/> URL: ${env.BUILD_URL}'""", cc: '', from: '', replyTo: '', subject: "'${currentBuild.result}'", to: 'devpay2022@gmail.com'
                
            }

    
            failure {
                emailext attachLog: true, attachmentsPattern: '.zip', body: """Hello,<br/> This is to inform you that the Project: ${env.JOB_NAME} has been failed.<br/> Here is the Build Number: ${env.BUILD_NUMBER} for your reference.<br/> You can get the details from this URL: ${env.BUILD_URL} and also I have attached the build cosole log, please take a look. Thanks.""", compressLog: true, mimeType: 'text/html', recipientProviders: [buildUser()], replyTo: 'devpay2022@gmail.com', subject: "This is the Build Status of last Jenkins job: ${currentBuild.result}", to: 'devpay2022@gmail.com'
                
                // mail bcc: '', body: """'Project: ${env.JOB_NAME}<br/> Build Number: ${env.BUILD_NUMBER}<br/> URL: ${env.BUILD_URL}'""", cc: '', from: '', replyTo: '', subject: "'${currentBuild.result}'", to: 'devpay2022@gmail.com'
                
            }
        }
              
    }   