@echo off
echo 🗑️ Deleting Ecommerce Microservices from Kubernetes...

REM Delete ingress
echo 🌐 Deleting ingress...
kubectl delete -f ingress.yml --ignore-not-found=true

REM Delete services
echo ⚙️ Deleting microservices...
kubectl delete -f api-gateway/deployment.yml --ignore-not-found=true
kubectl delete -f order/deployment.yml --ignore-not-found=true
kubectl delete -f product/deployment.yml --ignore-not-found=true
kubectl delete -f auth/deployment.yml --ignore-not-found=true

REM Delete secrets
echo 🔐 Deleting secrets...
kubectl delete -f order/secrets.yml --ignore-not-found=true
kubectl delete -f product/sercret.yml --ignore-not-found=true
kubectl delete -f auth/secrets.yml --ignore-not-found=true

REM Delete RabbitMQ
echo 🐰 Deleting RabbitMQ...
kubectl delete service rabbitmq --namespace=ecommerce --ignore-not-found=true
kubectl delete deployment rabbitmq --namespace=ecommerce --ignore-not-found=true

REM Delete database
echo 🗄️ Deleting MongoDB StatefulSet...
kubectl delete -f db/ --ignore-not-found=true

REM Delete PVCs (Persistent Volume Claims)
echo 🗂️ Deleting persistent volumes...
kubectl delete pvc -l app=mongodb -n ecommerce --ignore-not-found=true

REM Delete namespace (this will clean up anything left)
echo 📦 Deleting namespace...
kubectl delete -f namespace.yml --ignore-not-found=true

echo ✅ Cleanup complete!
echo 📊 Remaining resources (should be empty):
kubectl get all -n ecommerce 2>nul || echo    Namespace not found - cleanup successful!