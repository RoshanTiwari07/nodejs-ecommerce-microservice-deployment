# ---------- Builder Stage ----------
FROM node:14 AS builder

# Set working directory
WORKDIR /app

# Copy dependency files first
COPY package*.json ./

# Install all dependencies (including dev)
RUN npm install

# Copy the rest of the application files
COPY . .

# (Optional) Build step if needed (e.g. TypeScript, React, Next.js, NestJS)
# RUN npm run build


# ---------- Production Stage ----------
FROM node:14-slim AS production

# Set working directory
WORKDIR /app

# Copy only package.json and package-lock.json
COPY package*.json ./

# Install only production dependencies
RUN npm install --only=production

# Copy app code from builder stage
COPY --from=builder /app ./

# Expose the application port (adjust if not 3000)
EXPOSE 3000

# Run the app
CMD ["npm", "start"]
