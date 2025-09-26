#!/bin/bash
# Kind Cluster Management Script for Ecommerce Microservices

case "$1" in
    create)
        echo "🚀 Creating Kind cluster for ecommerce microservices..."
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
        
        # Install ingress controller
        echo "🌐 Installing NGINX Ingress Controller..."
        kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
        
        # Wait for ingress controller
        kubectl wait --namespace ingress-nginx \
            --for=condition=ready pod \
            --selector=app.kubernetes.io/component=controller \
            --timeout=90s
        
        echo "✅ Kind cluster 'ecommerce' created successfully!"
        ;;
    
    delete)
        echo "🗑️ Deleting Kind cluster..."
        kind delete cluster --name=ecommerce
        echo "✅ Kind cluster deleted successfully!"
        ;;
        
    status)
        echo "📊 Kind cluster status:"
        kind get clusters
        if kind get clusters | grep -q "ecommerce"; then
            echo "✅ Ecommerce cluster is running"
            kubectl cluster-info --context kind-ecommerce
        else
            echo "❌ Ecommerce cluster not found"
        fi
        ;;
        
    load-images)
        echo "📥 Loading latest Docker images into Kind cluster..."
        kind load docker-image roshan03ish/auth:latest --name=ecommerce 2>/dev/null || echo "   Auth image not found"
        kind load docker-image roshan03ish/product:latest --name=ecommerce 2>/dev/null || echo "   Product image not found"  
        kind load docker-image roshan03ish/order:latest --name=ecommerce 2>/dev/null || echo "   Order image not found"
        kind load docker-image roshan03ish/api-gateway:latest --name=ecommerce 2>/dev/null || echo "   API Gateway image not found"
        echo "✅ Image loading completed!"
        ;;
        
    *)
        echo "Usage: $0 {create|delete|status|load-images}"
        echo ""
        echo "Commands:"
        echo "  create      - Create Kind cluster with ingress"
        echo "  delete      - Delete Kind cluster"  
        echo "  status      - Show cluster status"
        echo "  load-images - Load Docker images into cluster"
        exit 1
        ;;
esac