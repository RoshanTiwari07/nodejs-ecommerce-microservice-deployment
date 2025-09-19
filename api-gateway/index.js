const express = require("express");
const httpProxy = require("http-proxy");

const proxy = httpProxy.createProxyServer();
const app = express();

// Health check endpoint for Kubernetes probes
app.get("/health", (req, res) => {
  res.status(200).json({ 
    status: "OK", 
    service: "API Gateway",
    timestamp: new Date().toISOString()
  });
});

// Root endpoint for basic checks
app.get("/", (req, res) => {
  res.status(200).json({ 
    message: "API Gateway is running",
    version: "1.0.0",
    endpoints: ["/auth", "/products", "/orders"]
  });
});

// Route requests to the auth service
app.use("/auth", (req, res) => {
  proxy.web(req, res, { target: "http://auth:3000" });
});

// Route requests to the product service
app.use("/products", (req, res) => {
  proxy.web(req, res, { target: "http://product:3001" });
});

// Route requests to the order service
app.use("/orders", (req, res) => {
  proxy.web(req, res, { target: "http://order:3002" });
});

// Start the server
const port = process.env.PORT || 3003;
app.listen(port, () => {
  console.log(`API Gateway listening on port ${port}`);
});
