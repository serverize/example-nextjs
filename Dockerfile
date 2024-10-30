FROM node:alpine AS base
RUN apk add --no-cache libc6-compat
WORKDIR /app


FROM base AS deps
WORKDIR /app
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./
RUN npm ci


FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ENV NEXT_TELEMETRY_DISABLED=1
RUN npm run build


FROM nginxinc/nginx-unprivileged AS start
WORKDIR /usr/share/nginx/html
COPY --from=builder /app/out .
ENV PORT=8080
USER nginx
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]