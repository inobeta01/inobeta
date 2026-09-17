# syntax=docker/dockerfile:1

# ---- Builder stage ----
FROM node:20-alpine AS builder
WORKDIR /app

# Install dependencies (including dev for build)
COPY package*.json ./
RUN npm ci

# Copy source files and build the Next.js app
COPY . ./
RUN npm run build

# ---- Production stage ----
FROM node:20-alpine AS runner
WORKDIR /app

# Copy only production dependencies
COPY --from=builder /app/package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

# Copy built assets
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.mjs ./

# Expose the Next.js default port
EXPOSE 3000

# Run the production server
CMD ["npm", "run", "start"]
