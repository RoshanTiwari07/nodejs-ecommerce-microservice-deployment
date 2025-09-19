# ---------- Builder Stage ----------
FROM node:14 AS builder

# Set working directory
WORKDIR /app

# Copy dependency files first (better cache layer)
COPY package*.json ./

# Install all dependencies (including dev)
RUN npm install

# Copy the rest of the source code
COPY . .

# (Optional) If you have a build step (TypeScript, React, Next.js, NestJS, etc.)
# RUN npm run build


# ---------- Production Stage ----------
FROM node:14-slim AS production

# Set working directory
WORKDIR /app

# Copy only package.json and package-lock.json
COPY package*.json ./

# Install only production dependencies
RUN npm install --only=production

# Copy application from builder stage
COPY --from=builder /app ./

# Expose application port (adjust if not 3000)
EXPOSE 3000

# Start the app
CMD ["npm", "start"]
