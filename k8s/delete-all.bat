@echo off
echo 🗑️ Deleting all Ecommerce Microservices from Kubernetes...

echo 📦 Deleting ingress...
kubectl delete -f ingress.yml --ignore-not-found=true

echo ⚙️ Deleting microservices...
kubectl delete -f api-gateway/deployment.yml --ignore-not-found=true
kubectl delete -f auth/deployment.yml --ignore-not-found=true
kubectl delete -f product/deployment.yml --ignore-not-found=true
kubectl delete -f order/deployment.yml --ignore-not-found=true

echo 🔐 Deleting secrets...
kubectl delete -f auth/secrets.yml --ignore-not-found=true
kubectl delete -f product/sercret.yml --ignore-not-found=true
kubectl delete -f order/secrets.yml --ignore-not-found=true

echo 🐰 Deleting RabbitMQ...
kubectl delete deployment rabbitmq --namespace=ecommerce --ignore-not-found=true
kubectl delete service rabbitmq --namespace=ecommerce --ignore-not-found=true

echo 🗄️ Deleting MongoDB...
kubectl delete -f db/ --ignore-not-found=true

echo 📦 Deleting namespace (this will remove everything inside)...
kubectl delete namespace ecommerce --ignore-not-found=true

echo ✅ Cleanup complete! Verifying deletion...
kubectl get all -n ecommerce

echo.
echo 🧹 All ecommerce microservices have been removed from Kubernetes!