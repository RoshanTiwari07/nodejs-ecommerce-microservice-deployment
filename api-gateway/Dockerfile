# ---------- Builder Stage ----------
FROM node:14 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# ---------- Production Stage ----------
FROM node:14-slim AS production
WORKDIR /app
COPY package*.json ./
RUN npm install --only=production
COPY --from=builder /app ./

EXPOSE 3000
CMD ["npm", "start"]

