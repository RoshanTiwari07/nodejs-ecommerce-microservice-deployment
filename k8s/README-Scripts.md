# Ecommerce Microservices - Enhanced Deployment Scripts

This project includes enhanced batch scripts for deploying, testing, and managing ecommerce microservices on Kubernetes with built-in service functionality testing.

## 📁 Available Scripts

### 🚀 `deploy-all.bat` - Enhanced Deployment
**Deploys all services AND tests functionality**
- ✅ Creates namespace and deploys all services
- ✅ Waits for pods to be ready (60 seconds)
- ✅ Tests all service health endpoints internally
- ✅ Verifies MongoDB and RabbitMQ connections
- ✅ Provides external access information

```bash
# Run deployment with testing
deploy-all.bat
```

### 🗑️ `delete-all.bat` - Enhanced Cleanup  
**Tests services before deletion and verifies cleanup**
- ✅ Tests service status before deletion
- ✅ Shows which services are active/inactive
- ✅ Performs complete cleanup
- ✅ Verifies successful deletion
- ✅ Handles terminating resources gracefully

```bash
# Run cleanup with verification
delete-all.bat
```

### 🔍 `test-services.bat` - Standalone Health Check
**Comprehensive service testing without deployment**
- ✅ Tests all service health endpoints
- ✅ Checks database and message broker status
- ✅ Shows ingress and external access information
- ✅ Provides complete system summary

```bash
# Test services anytime
test-services.bat
```

### 📊 `monitor-services.bat` - Continuous Monitoring
**Real-time service monitoring dashboard**
- ✅ Continuous health monitoring (15-second refresh)
- ✅ Real-time pod status updates
- ✅ Live service connectivity tests
- ✅ Database and message broker status
- ✅ Press Ctrl+C to stop

```bash
# Start continuous monitoring
monitor-services.bat
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

## 🎯 Usage Examples

### Quick Deployment and Test
```bash
# Deploy everything and verify functionality
deploy-all.bat

# Expected output:
# ✅ Auth Service: {"status":"OK","service":"Auth Service"}
# ✅ Product Service: {"status":"OK","service":"Product Service"}  
# ✅ Order Service: {"status":"OK","service":"Order Service"}
```

### Health Check Only
```bash
# Test without deploying
test-services.bat

# Shows comprehensive health status
```

### Continuous Monitoring
```bash
# Monitor services in real-time
monitor-services.bat

# Updates every 15 seconds with live status
```

### Clean Removal
```bash
# Remove everything with verification
delete-all.bat

# Shows what was running before deletion
# Verifies complete cleanup
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

## 🎉 Success Criteria

When everything is working correctly, you should see:
- ✅ All pods in "Running" state (8/8)
- ✅ All health endpoints returning OK status
- ✅ MongoDB accepting connections
- ✅ RabbitMQ message broker active  
- ✅ External access via ecommerce.local working
- ✅ No error messages in service logs

This enhanced deployment system provides comprehensive testing and monitoring for your backend microservices, ensuring reliable deployment and easy troubleshooting! 🚀