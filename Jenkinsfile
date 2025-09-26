pipeline {
    agent any

    options {
        timestamps()
        ansiColor('xterm')
        buildDiscarder(logRotator(numToKeepStr: '15'))
        timeout(time: 30, unit: 'MINUTES')
    }

    parameters {
        string(name: 'BACKEND_DOCKERTAG', defaultValue: 'latest', description: 'Tag for all backend Docker images')
    }

    environment {
        BIN_DIR = "${WORKSPACE}/.bin"
        PATH = "${BIN_DIR}:${env.PATH}"
        CLUSTER_NAME = "ecommerce-${BUILD_NUMBER}"
        NAMESPACE = "ecommerce"
        DOCKER_REPO = "roshan03ish"
    }

    stages {

        stage('Validate Input') {
            steps {
                script {
                    if (!params.BACKEND_DOCKERTAG?.trim()) {
                        error "BACKEND_DOCKERTAG must not be empty"
                    }
                    echo "🚀 Deploying Docker tag: ${params.BACKEND_DOCKERTAG}"
                }
            }
        }

        stage('Checkout Code') {
            steps {
                dir("${WORKSPACE}/repo") {
                    git branch: 'main', url: 'https://github.com/RoshanTiwari07/nodejs-ecommerce-microservice-deployment.git'
                }
            }
        }

        stage('Install Tools') {
            steps {
                sh """
                    mkdir -p "$BIN_DIR"
                    chmod 755 "$BIN_DIR"

                    # Check curl, chmod, docker
                    for cmd in curl chmod docker; do
                        if ! command -v \$cmd >/dev/null 2>&1; then
                            echo "❌ Required command \$cmd not found!"; exit 1;
                        fi
                    done

                    # Install kind
                    if ! command -v kind >/dev/null 2>&1; then
                        curl -Lo $BIN_DIR/kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
                        chmod +x $BIN_DIR/kind
                    fi

                    # Install kubectl
                    if ! command -v kubectl >/dev/null 2>&1; then
                        KVER=$(curl -L -s https://dl.k8s.io/release/stable.txt)
                        curl -Lo $BIN_DIR/kubectl https://dl.k8s.io/release/$KVER/bin/linux/amd64/kubectl
                        chmod +x $BIN_DIR/kubectl
                    fi

                    kind version
                    kubectl version --client
                """
            }
        }

        stage('Check Docker Images') {
            steps {
                sh """
                    for svc in auth product order api-gateway; do
                        echo "[INFO] Checking Docker image: ${DOCKER_REPO}/\$svc:${BACKEND_DOCKERTAG}"
                        if ! docker pull ${DOCKER_REPO}/\$svc:${BACKEND_DOCKERTAG}; then
                            echo "❌ Docker image ${DOCKER_REPO}/\$svc:${BACKEND_DOCKERTAG} not found!"
                            exit 1
                        fi
                    done
                """
            }
        }

        stage('Create Kind Cluster') {
            steps {
                sh """
                    echo "[INFO] Cleaning up any existing cluster with name ${CLUSTER_NAME}"
                    kind delete cluster --name="${CLUSTER_NAME}" || true

                    echo "[INFO] Creating new Kind cluster ${CLUSTER_NAME}"
                    kind create cluster --name="${CLUSTER_NAME}" --wait=120s

                    # Load Docker images into Kind
                    for svc in auth product order api-gateway; do
                        kind load docker-image ${DOCKER_REPO}/\$svc:${BACKEND_DOCKERTAG} --name ${CLUSTER_NAME}
                    done
                """
            }
        }

        stage('Patch Kubernetes Manifests') {
            steps {
                sh """
                    cd ${WORKSPACE}/repo/k8s
                    for svc in auth product order api-gateway; do
                        sed -i "s|image: ${DOCKER_REPO}/\$svc:.*|image: ${DOCKER_REPO}/\$svc:${BACKEND_DOCKERTAG}|g" \$svc/deployment.yml
                    done
                    echo "[INFO] Manifests updated"
                """
            }
        }

        stage('Deploy Kubernetes Resources') {
            steps {
                sh """
                    kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
                    
                    # Apply DB first
                    kubectl apply -n ${NAMESPACE} -f ${WORKSPACE}/repo/k8s/db

                    # Wait for DB pods
                    kubectl wait --for=condition=ready pod -l app=db -n ${NAMESPACE} --timeout=120s

                    # Apply services
                    for svc in auth product order api-gateway; do
                        kubectl apply -n ${NAMESPACE} -f ${WORKSPACE}/repo/k8s/\$svc
                        kubectl rollout status deployment/\$svc -n ${NAMESPACE} --timeout=120s
                    done
                """
            }
        }

        stage('Verify Deployment') {
            steps {
                sh """
                    kubectl get pods -n ${NAMESPACE} -o wide
                    kubectl get svc -n ${NAMESPACE}

                    # Simple health check
                    POD=$(kubectl get pod -n ${NAMESPACE} -l app=api-gateway -o jsonpath='{.items[0].metadata.name}')
                    kubectl exec -n ${NAMESPACE} \$POD -- curl -fsS http://localhost:3003/health || echo "⚠️ Health check failed"
                """
            }
        }
    }

    post {
        success {
            echo "✅ Deployment completed successfully for tag ${BACKEND_DOCKERTAG}"
        }
        failure {
            echo "❌ Deployment failed! Collecting diagnostics..."
            sh """
                kubectl get ns ${NAMESPACE} || true
                kubectl get all -n ${NAMESPACE} || true
                kubectl describe pods -n ${NAMESPACE} || true
                kubectl get events -n ${NAMESPACE} --sort-by=.lastTimestamp | tail -n 50 || true

                echo "[CLEANUP] Deleting Kind cluster ${CLUSTER_NAME}"
                kind delete cluster --name="${CLUSTER_NAME}" || true
            """
        }
        always {
            echo "🏁 Pipeline finished"
        }
    }
}
