# ---------- Builder Stage ----------
FROM node:14 AS builder

# Set the working directory
WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install all dependencies (including dev)
RUN npm install

# Copy the rest of the source code
COPY . .

# (Optional) Build step if your app requires it (e.g. React, Nest, Next)
# RUN npm run build


# ---------- Production Stage ----------
FROM node:14-slim AS production

# Set the working directory
WORKDIR /app

# Copy only package.json & lock file
COPY package*.json ./

# Install only production dependencies
RUN npm install --only=production

# Copy built app (or raw source if no build step) from builder
COPY --from=builder /app ./

# Expose the app port (adjust if needed)
EXPOSE 3000

# Start the app
CMD ["npm", "start"]
