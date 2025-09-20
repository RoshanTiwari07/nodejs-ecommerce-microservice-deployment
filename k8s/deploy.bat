@echo off
setlocal enabledelayedexpansion
echo 🚀 Deploying Ecommerce Microservices to Kubernetes...

REM Create namespace
echo 📦 Creating namespace...
kubectl apply -f namespace.yml

REM Deploy database
echo 🗄️ Deploying MongoDB StatefulSet...
kubectl apply -f db/

REM Deploy RabbitMQ
echo 🐰 Deploying RabbitMQ...
kubectl create deployment rabbitmq --image=rabbitmq:3-management --namespace=ecommerce 2>nul || echo    RabbitMQ deployment already exists
kubectl expose deployment rabbitmq --port=5672 --target-port=5672 --namespace=ecommerce 2>nul || echo    RabbitMQ service already exists

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
echo ⏳ Waiting for pods to be ready (30 seconds)...
timeout /t 30 /nobreak >nul

echo.
echo 🔍 Backend Response Test:
echo 🗄️ MongoDB Status:
kubectl get pods -n ecommerce -l app=mongodb --no-headers | findstr Running >nul && echo    ✅ MongoDB pod is running || echo    ❌ MongoDB pod not running

echo 🔐 Auth Service Response:
kubectl exec deployment/api-gateway -n ecommerce -- node -e "const http = require('http'); http.get('http://auth:3000/health', (res) => { let data = ''; res.on('data', chunk => data += chunk); res.on('end', () => console.log('   ', data)); }).on('error', err => console.log('    ❌ Error:', err.message));"

echo 📊 All Pods:
kubectl get pods -n ecommerce

echo.
echo 🌍 Access Information:
echo 1. Add '192.168.49.2 ecommerce.local' to your hosts file
echo 2. Run 'minikube tunnel' (if not already running) 
echo 3. Access: http://ecommerce.local/api/product/health