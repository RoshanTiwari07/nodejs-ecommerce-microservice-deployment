#!/bin/bash
set -e

echo "🚀 Deploying Ecommerce Microservices to Kind Kubernetes..."

# Check if Kind cluster exists
if ! kind get clusters | grep -q "ecommerce"; then
    echo "📦 Creating Kind cluster..."
    cat << EOF > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
  - containerPort: 443
    hostPort: 443
  - containerPort: 30000
    hostPort: 30000
EOF
    kind create cluster --config=kind-config.yaml --name=ecommerce
    
    # Wait for cluster to be ready
    echo "⏳ Waiting for cluster to be ready..."
    sleep 10
    
    # Wait for API server to be ready
    echo "🔌 Waiting for API server to be ready..."
    timeout=120
    while [ $timeout -gt 0 ]; do
        if kubectl cluster-info --context kind-ecommerce &>/dev/null; then
            echo "✅ API server is ready!"
            break
        fi
        echo "   Still waiting for API server... ($timeout seconds left)"
        sleep 5
        timeout=$((timeout - 5))
    done
    
    kubectl wait --for=condition=ready nodes --all --timeout=60s
    
    # Install ingress controller
    echo "🌐 Installing NGINX Ingress Controller..."
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
    
    # Wait for ingress controller
    kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=90s
fi

echo "📦 Creating namespace..."
kubectl apply -f namespace.yml

# Load Docker images into Kind cluster
echo "📥 Loading Docker images into Kind cluster..."
if docker images | grep -q "roshan03ish/auth"; then
    kind load docker-image roshan03ish/auth:latest --name=ecommerce || echo "   Auth image not found locally"
fi
if docker images | grep -q "roshan03ish/product"; then
    kind load docker-image roshan03ish/product:latest --name=ecommerce || echo "   Product image not found locally"
fi  
if docker images | grep -q "roshan03ish/order"; then
    kind load docker-image roshan03ish/order:latest --name=ecommerce || echo "   Order image not found locally"
fi
if docker images | grep -q "roshan03ish/api-gateway"; then
    kind load docker-image roshan03ish/api-gateway:latest --name=ecommerce || echo "   API Gateway image not found locally"
fi

# Deploy database
echo "🗄️ Deploying MongoDB StatefulSet..."
kubectl apply -f db/

# Deploy RabbitMQ
echo "🐰 Deploying RabbitMQ..."
kubectl create deployment rabbitmq --image=rabbitmq:3-management --namespace=ecommerce 2>/dev/null || echo "   RabbitMQ deployment already exists"
kubectl expose deployment rabbitmq --port=5672 --target-port=5672 --namespace=ecommerce 2>/dev/null || echo "   RabbitMQ service already exists"
kubectl expose deployment rabbitmq --port=15672 --target-port=15672 --name=rabbitmq-management --namespace=ecommerce 2>/dev/null || echo "   RabbitMQ management service already exists"

# Deploy secrets
echo "🔐 Deploying secrets..."
kubectl apply -f auth/secrets.yml
kubectl apply -f product/secret.yml
kubectl apply -f order/secrets.yml

# Deploy services
echo "⚙️ Deploying microservices..."
kubectl apply -f auth/deployment.yml
kubectl apply -f product/deployment.yml
kubectl apply -f order/deployment.yml
kubectl apply -f api-gateway/deployment.yml

# Deploy ingress
echo "🌐 Deploying ingress..."
kubectl apply -f ingress.yml

echo "✅ Deployment complete! Checking status..."
kubectl get all -n ecommerce

echo ""
echo "⏳ Waiting for pods to be ready (60 seconds)..."
sleep 60

echo ""
echo "🔍 Backend Response Test:"
echo "🗄️ MongoDB Status:"
if kubectl get pods -n ecommerce -l app=mongodb --no-headers 2>/dev/null | grep -q Running; then
    echo "   ✅ MongoDB pod is running"
else
    echo "   ❌ MongoDB pod not running"
fi

echo "🔐 Auth Service Health Check:"
kubectl exec deployment/api-gateway -n ecommerce -- timeout 10 wget -q -O- http://auth:3000/health 2>/dev/null || echo "   ⚠️ Auth service not ready yet"

echo "📊 All Pods:"
kubectl get pods -n ecommerce

echo ""
echo "🌍 Access Information:"
echo "1. Services are accessible via NodePort or Port Forward"
echo "2. API Gateway: kubectl port-forward svc/api-gateway 3003:3003 -n ecommerce"
echo "3. RabbitMQ Management: kubectl port-forward svc/rabbitmq-management 15672:15672 -n ecommerce"
echo "4. Health Check: curl http://localhost:3003/health"
echo ""
echo "🎉 Kind deployment completed successfully!"