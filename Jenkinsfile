@Library('Shared-lib') _
pipeline{
    agent any 

    environment{
        SONAR_HOME = tool "Sonar"
    }

    parameters{
        string(name: 'BACKEND_DOCKERTAG', defaultValue: 'latest', description: 'Tag for the backend Docker image')
    }
    
    stages{
        stage("Validate parameters"){
            steps{
                script {
                    if(params.BACKEND_DOCKERTAG == ''){
                        error("Docker image tags for backend must be provided.")
                    }
                }
            }
        }
        stage("Workspace Cleanup"){
            steps{
                script {
                    cleanWs()
                }
            }
        }
        stage("Git: Code Checkout"){
            steps{
                script {
                    code_checkout("https://github.com/RoshanTiwari07/nodejs-ecommerce-microservice-deployment.git", "main")
                }
            }
        }
        stage("Trivy: Filesystem Scanning"){
            steps{
                script {
                    trivy_scan()
                }
            }
        }
        stage("OWASP: Dependency check"){
            steps{
                script{
                    owasp_dependency()
                }
            }
        }
        stage("SonarQube: Code Analysis"){
            steps{
                script{
                    sonarqube_analysis("Sonar","ecommerce","ecommerce")
                }
            }
        }
        stage("SonarQube: Code Quality Gates"){
            steps{
                script{
                    sonarqube_code_quality()
                }
            }
        }
        stage("Docker: Build"){
            parallel{
                stage("API Gateway"){
                    steps{
                        script{
                            dir('api-gateway'){
                                sh """
                                    docker build -t roshan03ish/api-gateway:${params.BACKEND_DOCKERTAG} .
                                    docker tag roshan03ish/api-gateway:${params.BACKEND_DOCKERTAG} roshan03ish/api-gateway:latest
                                """
                                docker_push("roshan03ish/api-gateway", "${params.BACKEND_DOCKERTAG}","roshan03ish")
                            }
                        }
                    }
                }
                stage("Auth Service"){
                    steps{
                        script{
                            dir('auth'){
                                sh """
                                    docker build -t roshan03ish/auth:${params.BACKEND_DOCKERTAG} .
                                    docker tag roshan03ish/auth:${params.BACKEND_DOCKERTAG} roshan03ish/auth:latest
                                """
                                docker_push("roshan03ish/auth", "${params.BACKEND_DOCKERTAG}","roshan03ish")
                            }
                        }
                    }

                }
                stage("Product Service"){
                    steps{
                        script{
                            dir('product'){
                                sh """
                                    docker build -t roshan03ish/product:${params.BACKEND_DOCKERTAG} .
                                    docker tag roshan03ish/product:${params.BACKEND_DOCKERTAG} roshan03ish/product:latest
                                """
                                docker_push("roshan03ish/product", "${params.BACKEND_DOCKERTAG}","roshan03ish")
                            }
                        }
                    }
                }
                stage("Order Service"){
                    steps{
                        script{
                            dir('order'){
                                sh """
                                    docker build -t roshan03ish/order:${params.BACKEND_DOCKERTAG} .
                                    docker tag roshan03ish/order:${params.BACKEND_DOCKERTAG} roshan03ish/order:latest
                                """
                                docker_push("roshan03ish/order", "${params.BACKEND_DOCKERTAG}","roshan03ish")
                            }
                        }
                    }
                }
            }
        }
        stage("Docker Image Security Scan"){
            steps{
                script{
                    sh "trivy image roshan03ish/auth:${params.BACKEND_DOCKERTAG}"
                    sh "trivy image roshan03ish/product:${params.BACKEND_DOCKERTAG}"
                    sh "trivy image roshan03ish/api-gateway:${params.BACKEND_DOCKERTAG}"
                    sh "trivy image roshan03ish/order:${params.BACKEND_DOCKERTAG}"
                }
            }
        }
        // Missing - cleanup local images after push
        stage("Cleanup"){
            steps{
                script{
                    sh """
                        docker rmi roshan03ish/auth:${params.BACKEND_DOCKERTAG} || true
                        docker rmi roshan03ish/product:${params.BACKEND_DOCKERTAG} || true
                        docker rmi roshan03ish/order:${params.BACKEND_DOCKERTAG} || true
                        docker rmi roshan03ish/api-gateway:${params.BACKEND_DOCKERTAG} || true
                    """
                }
            }
        }
    }
    
    post{
        success{
            archiveArtifacts artifacts: '*.xml', followSymlinks: false
            build job: "ecommerce-CD", parameters: [
                string(name: 'BACKEND_DOCKERTAG', value: "${params.BACKEND_DOCKERTAG}")
            ]
        }
    }
}

