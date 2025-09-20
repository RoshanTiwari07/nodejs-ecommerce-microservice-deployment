# 🛒 Node.js Ecommerce Microservices

> **One-Click Kubernetes Deployment** | Complete microservices architecture with automated backend testing

A production-ready microservice sample for building scalable e-commerce backends with **automated Kubernetes deployment** and built-in connectivity testing.

📖 **Medium Article**: [Building Scalable E-commerce Backend with Microservices](https://medium.com/@nicholasgcc/building-scalable-e-commerce-backend-with-microservices-exploring-design-decisions-node-js-b5228080403b)

## 🚀 **Quick Start - Deploy in One Click!**

```bash
# 1. Navigate to k8s folder
cd k8s

# 2. Deploy everything + test backend connectivity
.\deploy.bat

# 3. Clean up when done
.\delete.bat
```

**What you get:**
- ✅ **8 microservices running** on Kubernetes
- ✅ **MongoDB database** with persistent storage
- ✅ **RabbitMQ message broker** for async communication
- ✅ **Nginx ingress** for external access
- ✅ **Backend connectivity proof** - see auth service respond with `{"status":"OK"}`

---

## 🏗️ Software Architecture

<img width="810" alt="image" src="https://user-images.githubusercontent.com/69677864/223613048-384c48cd-f846-4741-9b0d-90fbb2442590.png">

### 🔧 **Architecture Overview**
- **API Gateway** (`:3003`) - Single entry point, routes requests to microservices
- **Auth Service** (`:3000`) - User authentication, JWT tokens, MongoDB integration
- **Product Service** (`:3001`) - Product catalog management, inventory tracking
- **Order Service** (`:3002`) - Order processing, payment handling
- **MongoDB** - Primary database for all services with persistent volumes
- **RabbitMQ** - Message broker for async communication between services

### 🔄 **Service Communication**
- **Synchronous**: API Gateway ↔ Microservices (HTTP/REST)
- **Asynchronous**: Product ↔ Order services via [AMQP](https://www.amqp.org) protocol
- **Message Queues**: `orders` and `products` queues for efficient resource usage
- **Event-Driven**: Order events trigger product inventory updates automatically

## 🏛️ Microservice Structure

<img width="678" alt="image" src="https://user-images.githubusercontent.com/69677864/223522265-3a585a38-0148-4921-bfea-fd19989c8bff.png">

### 🎯 **Clean Architecture Implementation**
Each microservice follows **Uncle Bob's [Clean Architecture](https://www.freecodecamp.org/news/a-quick-introduction-to-clean-architecture-990c014448d2)** principles:

```
📁 src/
├── 🎮 controllers/     # HTTP request handlers
├── 🔧 services/        # Business logic layer  
├── 🗄️ repositories/    # Data access layer
├── 📋 models/          # Domain entities
├── ⚙️ config/          # Configuration management
├── 🛡️ middlewares/     # Request/response processing
└── 🧪 test/           # Unit and integration tests
```

**Benefits:**
- ✅ **Strong modularity** - Clear separation of concerns
- ✅ **Loose coupling** - Easy to modify and extend
- ✅ **Dependency injection** - Testable and maintainable
- ✅ **Domain-driven design** - Business logic isolation

### 🛠️ **Tech Stack**
| Component | Technology | Purpose |
|-----------|------------|---------|
| **Runtime** | Node.js 18+ | JavaScript server environment |
| **Framework** | Express.js | Web application framework |
| **Database** | MongoDB | Document-based NoSQL database |
| **Message Broker** | RabbitMQ | Async communication |
| **Containerization** | Docker | Application packaging |
| **Orchestration** | Kubernetes | Container management |
| **Testing** | Mocha + Chai | Unit and integration testing |
| **Authentication** | JWT | Secure token-based auth |

## 📋 Prerequisites

### ⚡ **For Kubernetes Deployment (Recommended)**
```bash
# Required tools
✅ kubectl          # Kubernetes command-line tool
✅ minikube         # Local Kubernetes cluster
✅ Docker Desktop   # Container runtime

# Verify installation
kubectl version --client
minikube version
docker --version
```

### 🖥️ **For Local Development**
```bash
# Development tools
✅ Node.js 18+      # JavaScript runtime
✅ npm/yarn         # Package manager  
✅ MongoDB          # Database server
✅ RabbitMQ         # Message broker

# Verify installation
node --version
npm --version
```

## 🚀 Deployment Options

### 🎯 **Option 1: Kubernetes (One-Click) - RECOMMENDED**

**Deploy everything in 30 seconds:**
```bash
# Start your cluster
minikube start

# Navigate and deploy
cd k8s
.\deploy.bat
```

**What happens:**
1. 📦 **Creates namespace** and deploys all services
2. ⏳ **Waits 30 seconds** for pods to start
3. 🔍 **Tests connectivity** - MongoDB + Auth service response
4. ✅ **Shows success** - All 8 pods running

**Example output:**
```
🔍 Backend Response Test:
🗄️ MongoDB Status: ✅ MongoDB pod is running 
🔐 Auth Service Response: {"status":"OK","service":"Auth Service"}
📊 All Pods: [8 pods running]
```

**Access your services:**
```bash
# Add to hosts file (optional)
echo 192.168.49.2 ecommerce.local >> C:\Windows\System32\drivers\etc\hosts

# Start tunnel (separate terminal)
minikube tunnel

# Test endpoints
curl http://ecommerce.local/api/auth/health
curl http://ecommerce.local/api/product/health
```

**Cleanup:**
```bash
.\delete.bat  # Removes everything
```

---

### 🐳 **Option 2: Docker Compose**

```bash
# 1. Setup environment files
cp auth/env.example auth/.env
cp product/env.example product/.env  
cp order/env.example order/.env

# 2. Build and run
docker-compose build
docker-compose up

# 3. Access APIs
curl http://localhost:3003/api/auth/health
```

---

### 💻 **Option 3: Local Development**

```bash
# 1. Install dependencies (run in each service folder)
cd auth && npm install
cd ../product && npm install  
cd ../order && npm install
cd ../api-gateway && npm install

# 2. Setup environment files
cp auth/env.example auth/.env
cp product/env.example product/.env
cp order/env.example order/.env

# 3. Start services (separate terminals)
cd auth && npm start          # Port 3000
cd product && npm start       # Port 3001  
cd order && npm start         # Port 3002
cd api-gateway && npm start   # Port 3003

# 4. Test APIs
curl http://localhost:3003/api/auth/health
```

## 🌐 **API Endpoints**

| Service | Endpoint | Purpose |
|---------|----------|---------|
| **Auth** | `POST /api/auth/register` | User registration |
| **Auth** | `POST /api/auth/login` | User login |
| **Auth** | `GET /api/auth/health` | Health check |
| **Product** | `GET /api/products` | List products |
| **Product** | `POST /api/products` | Create product |
| **Product** | `GET /api/product/health` | Health check |
| **Order** | `GET /api/orders` | List orders |
| **Order** | `POST /api/orders` | Create order |
| **Order** | `GET /api/order/health` | Health check |
| **Gateway** | `/*` | Routes to services |

## 🎯 **Project Features**

### ✅ **What's Included**
- 🚀 **One-click Kubernetes deployment** with automated testing
- 🏗️ **Complete microservices architecture** (API Gateway + 3 services)
- 🗄️ **MongoDB StatefulSet** with persistent storage
- 🐰 **RabbitMQ message broker** for async communication
- 🌐 **Nginx ingress** for external access
- 🔐 **JWT authentication** with secure token handling
- 🛡️ **Health checks** and monitoring endpoints
- 🧪 **Automated connectivity testing** - proves backend works
- 📊 **Resource limits** and horizontal pod autoscaling ready

### 🔍 **Backend Connectivity Proof**
The deployment script automatically tests:
- ✅ **MongoDB connection** - Database ready and accessible
- ✅ **Auth service response** - API responding with health status
- ✅ **All pods running** - Complete system operational
- ✅ **Inter-service communication** - Services can talk to each other

## 🚨 **Troubleshooting**

### Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| **Pods not starting** | `kubectl describe pod <pod-name> -n ecommerce` |
| **Services not responding** | Check logs: `kubectl logs <pod-name> -n ecommerce` |
| **External access fails** | Verify hosts file and `minikube tunnel` |
| **MongoDB connection error** | Check MongoDB pod: `kubectl get pods -n ecommerce -l app=mongodb` |
| **Auth service timeout** | Wait longer, services need time to start |

### Quick Fixes
```bash
# Restart everything
.\delete.bat && .\deploy.bat

# Check pod status
kubectl get pods -n ecommerce

# View service logs
kubectl logs deployment/auth -n ecommerce

# Test internal connectivity
kubectl exec -it deployment/api-gateway -n ecommerce -- curl http://auth:3000/health
```

## 🎉 **Success Indicators**

You know everything is working when you see:
```
✅ MongoDB pod is running 
✅ Auth Service Response: {"status":"OK","service":"Auth Service"}
✅ All 8 pods in Running state
✅ No error messages in deployment output
```

## 🛣️ **Future Enhancements**

### 🔮 **Roadmap**
- [ ] **Helm charts** for production deployment
- [ ] **CI/CD pipeline** with GitHub Actions
- [ ] **Monitoring stack** (Prometheus + Grafana)
- [ ] **Service mesh** integration (Istio)
- [ ] **Database sharding** for scalability
- [ ] **API rate limiting** and throttling
- [ ] **Distributed tracing** with Jaeger
- [ ] **End-to-end testing** automation

### 🧪 **Testing Improvements**
- [ ] **TDD implementation** - Test-driven development
- [ ] **Integration test suite** - Complete API workflow testing
- [ ] **Load testing** - Performance benchmarking
- [ ] **Security testing** - Vulnerability scanning
- [ ] **Contract testing** - Service interface validation

### 🏗️ **Architecture Enhancements**
- [ ] **Pure dependency injection** - Full Clean Architecture compliance
- [ ] **Event sourcing** - Complete audit trail
- [ ] **CQRS pattern** - Command Query Responsibility Segregation
- [ ] **Multi-database support** - PostgreSQL, Firebase options
- [ ] **Cache layer** - Redis integration

---

## 📖 **Learn More**

- 📝 **Medium Article**: [Building Scalable E-commerce Backend](https://medium.com/@nicholasgcc/building-scalable-e-commerce-backend-with-microservices-exploring-design-decisions-node-js-b5228080403b)
- 🏛️ **Clean Architecture**: [Uncle Bob's Architecture Guide](https://www.freecodecamp.org/news/a-quick-introduction-to-clean-architecture-990c014448d2)
- ☸️ **Kubernetes Docs**: [Official Documentation](https://kubernetes.io/docs/)
- 🐰 **RabbitMQ Guide**: [Message Broker Tutorial](https://www.rabbitmq.com/tutorials/tutorial-one-javascript.html)

---

## ⭐ **Star this project** if you found it helpful!

**Happy coding!** 🚀
