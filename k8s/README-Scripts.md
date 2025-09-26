# Ecommerce Microservices - Kind Kubernetes Deployment Scripts

This project includes Linux shell scripts for deploying and managing ecommerce microservices on Kind (Kubernetes in Docker) clusters, optimized for EC2 t3.large instances.

## � One-Click Deployment

### ⚡ **Quick Start** - Deploy Everything in One Click!

```bash
# Navigate to k8s folder and run:
cd k8s
.\deploy.bat
```

**What happens when you run deploy.bat:**
1. ✅ Creates namespace and deploys all services  
2. ✅ Waits for pods to be ready (30 seconds)
3. ✅ **Tests backend connectivity** - Shows MongoDB status + Auth service response
4. ✅ Displays all pod status
5. ✅ Provides access information

### 🗑️ **Quick Cleanup** - Delete Everything in One Click!

```bash
# Clean up everything:
.\delete.bat
```

## 📁 Available Scripts

### � `deploy.bat` - One-Click Deployment
**Deploy all microservices with backend connectivity proof**
- ✅ Deploys MongoDB, RabbitMQ, Auth, Product, Order, API Gateway
- ✅ Tests MongoDB pod status
- ✅ **Shows Auth service response** (proves backend is working)
- ✅ Lists all running pods

```bash
.\deploy.bat
```

**Example Output:**
```
🔍 Backend Response Test:
🗄️ MongoDB Status:
   ✅ MongoDB pod is running 
🔐 Auth Service Response:
    {"status":"OK","service":"Auth Service","timestamp":"2025-09-20T06:54:43.528Z"}
📊 All Pods: [shows all 8 pods running]
```

### �️ `delete.bat` - One-Click Cleanup
**Complete cleanup with verification**
- ✅ Removes all deployments, services, secrets
- ✅ Deletes persistent volumes
- ✅ Cleans up namespace
- ✅ Verifies successful removal

```bash
.\delete.bat
```

## 🏗️ System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Auth Service  │    │ Product Service │    │  Order Service  │
│     :3000       │    │      :3001      │    │      :3002      │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌─────────────┴───────────┐
                    │   API Gateway :3003     │
                    └─────────────┬───────────┘
                                  │
                         ┌────────┴────────┐
                         │  Ingress (Nginx) │
                         │  ecommerce.local │
                         └─────────────────┘

External Dependencies:
├── MongoDB (StatefulSet) - Database
└── RabbitMQ - Message Broker
```

## ⚙️ Service Testing Features

### Internal Health Checks
All scripts test internal service connectivity using:
```javascript
// Example health check performed by scripts
http.get('http://auth:3000/health', callback)
http.get('http://product:3001/health', callback)  
http.get('http://order:3002/health', callback)
```

### External Access Testing
Scripts provide endpoints for external testing:
- `http://ecommerce.local/api/auth/health`
- `http://ecommerce.local/api/product/health`
- `http://ecommerce.local/api/order/health`

### Database Connectivity
- Tests MongoDB connection and ready state
- Verifies RabbitMQ message broker status
- Checks persistent volume claims

## 🔧 Prerequisites

1. **Kubernetes cluster** (Minikube, Docker Desktop, etc.)
2. **kubectl** configured and connected
3. **Ingress controller** (nginx) installed
4. **Docker images** available:
   - `roshan03ish/auth:v1`
   - `roshan03ish/product:v1`
   - `roshan03ish/order:v1`
   - `roshan03ish/api-gateway:v3`

## 🌐 External Access Setup

1. **Add to hosts file** (`C:\Windows\System32\drivers\etc\hosts`):
   ```
   192.168.49.2 ecommerce.local
   ```

2. **Start tunnel** (for Minikube):
   ```bash
   minikube tunnel
   ```

3. **Test external access**:
   ```bash
   curl http://ecommerce.local/api/product/health
   ```

## 📊 What Gets Tested

### ✅ Service Health Endpoints
- Auth Service: MongoDB connection + JWT functionality
- Product Service: API functionality
- Order Service: RabbitMQ connection + order processing
- API Gateway: Request routing

### ✅ Infrastructure Components  
- MongoDB: Database ready state and connectivity
- RabbitMQ: Message broker status
- Ingress: External routing configuration
- Persistent Volumes: Data persistence

### ✅ Pod Status Monitoring
- Running/Ready state of all pods
- Resource utilization warnings
- Restart counts and error states

## 🎯 Root Commands to Run

### 🏁 **Step 1: Prerequisites**
Make sure you have these running:
```bash
# Start Minikube (if using Minikube)
minikube start

# Verify kubectl works
kubectl cluster-info
```

### 🚀 **Step 2: One-Click Deploy**
```bash
# Navigate to project root
cd "c:\Myprojects\ecommerce microservice project\nodejs-ecommerce-microservice-deployment-"

# Go to k8s folder  
cd k8s

# Deploy everything in one click!
.\deploy.bat
```

**You'll see:**
- 📦 All services deploying
- ⏳ 30-second wait for pods
- ✅ MongoDB status: "MongoDB pod is running"
- 🔐 Auth response: `{"status":"OK","service":"Auth Service","timestamp":"..."}`
- 📊 All 8 pods running

### 🌐 **Step 3: Access Your Services** (Optional)
```bash
# Add to hosts file (as admin):
echo 192.168.49.2 ecommerce.local >> C:\Windows\System32\drivers\etc\hosts

# Start tunnel (separate terminal):
minikube tunnel

# Test external access:
curl http://ecommerce.local/api/product/health
```

### 🗑️ **Cleanup When Done**
```bash
# Remove everything in one click:  
.\delete.bat
```

## 💡 **TL;DR - Just 2 Commands:**
```bash
cd "c:\Myprojects\ecommerce microservice project\nodejs-ecommerce-microservice-deployment-\k8s"
.\deploy.bat     # Deploy + test backend
.\delete.bat     # Clean up everything
```

## 🔒 Security Features

- **ConfigMap/Secret Integration**: Database credentials stored securely
- **Namespace Isolation**: All resources in dedicated `ecommerce` namespace  
- **Resource Limits**: Memory and CPU limits to prevent resource exhaustion
- **Health Probes**: Kubernetes liveness and readiness probes configured

## 🚨 Troubleshooting

### Common Issues:

1. **Services not responding**: Wait longer after deployment (pods may need more time to start)
2. **External access fails**: Check hosts file and ensure `minikube tunnel` is running
3. **Database connection errors**: Verify MongoDB pod is running and ConfigMap/Secret are applied
4. **Message broker issues**: Check RabbitMQ pod logs and service connectivity

### Debug Commands:
```bash
# Check pod status
kubectl get pods -n ecommerce

# Check service logs  
kubectl logs <pod-name> -n ecommerce

# Test internal connectivity
kubectl exec -it <api-gateway-pod> -n ecommerce -- curl http://auth:3000/health
```

## ✅ **What Success Looks Like**

After running `.\deploy.bat`, you should see:
```
🔍 Backend Response Test:
🗄️ MongoDB Status:
   ✅ MongoDB pod is running 
🔐 Auth Service Response:
    {"status":"OK","service":"Auth Service","timestamp":"2025-09-20T06:54:43.528Z"}
📊 All Pods:
NAME                          READY   STATUS    RESTARTS   AGE
api-gateway-xxx-xxx           1/1     Running   0          1m
auth-xxx-xxx                  1/1     Running   0          1m
mongodb-0                     1/1     Running   0          1m
order-xxx-xxx                 1/1     Running   0          1m
product-xxx-xxx               1/1     Running   0          1m
rabbitmq-xxx-xxx              1/1     Running   0          1m
```

**This proves your backend is working!** 🎉

- ✅ **8 pods running** (all microservices deployed)
- ✅ **MongoDB connected** (database ready)  
- ✅ **Auth service responding** (backend API working)
- ✅ **Ready for development/testing**

## 🚨 Troubleshooting

**If MongoDB shows "not running":**
```bash
kubectl get pods -n ecommerce -l app=mongodb
```

**If Auth service doesn't respond:**
```bash  
kubectl logs deployment/auth -n ecommerce
```

**Quick fix - redeploy:**
```bash
.\delete.bat
.\deploy.bat
```

---

## 🎖️ **That's it!** 
**One command deploys everything + proves your backend works!** 🚀