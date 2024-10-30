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
RUN mkdir -p ./public
RUN npm run build


FROM base AS start
WORKDIR /app
COPY --from=deps /app/node_modules node_modules
COPY --from=builder /app/public public
COPY --from=builder /app/.next/static .next/static
COPY --from=builder /app/.next/standalone .
ENV NODE_ENV=production
ENV HOSTNAME=0.0.0.0
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
USER node
EXPOSE 3000
CMD ["node", "server.js"]