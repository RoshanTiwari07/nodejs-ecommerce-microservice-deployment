@echo off
echo 🚀 Deploying Ecommerce Microservices to Kubernetes...

REM Create namespace
echo 📦 Creating namespace...
kubectl apply -f namespace.yml

REM Deploy database
echo 🗄️ Deploying MongoDB StatefulSet...
kubectl apply -f db/

REM Deploy RabbitMQ
echo 🐰 Deploying RabbitMQ...
kubectl create deployment rabbitmq --image=rabbitmq:3-management --namespace=ecommerce
kubectl expose deployment rabbitmq --port=5672 --target-port=5672 --namespace=ecommerce

REM Deploy secrets
echo 🔐 Deploying secrets...
kubectl apply -f auth/secrets.yml
kubectl apply -f product/sercret.yml
kubectl apply -f order/secrets.yml

REM Deploy services
echo ⚙️ Deploying microservices...
kubectl apply -f auth/deployment.yml
kubectl apply -f product/deployment.yml
kubectl apply -f order/deployment.yml
kubectl apply -f api-gateway/deployment.yml

REM Deploy ingress
echo 🌐 Deploying ingress...
kubectl apply -f ingress.yml

echo ✅ Deployment complete! Checking status...
kubectl get all -n ecommerce

echo.
echo 🌍 To access the application:
echo 1. Add '127.0.0.1 ecommerce.local' to your hosts file
echo 2. Run 'minikube tunnel'
echo 3. Access: http://ecommerce.local