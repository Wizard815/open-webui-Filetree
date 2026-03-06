# syntax=docker/dockerfile:1

# Minimal Dockerfile for your Filetree fork that:
# - Builds the frontend from your local source
# - Reuses the official Open WebUI runtime image (so Python deps like uvicorn are already installed)
# - Adds your corporate CA so HTTPS works behind the proxy

ARG BUILD_HASH=dev-build

######## WebUI frontend (build from your tree) ########
FROM --platform=$BUILDPLATFORM node:22-bookworm-slim AS build
ARG BUILD_HASH

WORKDIR /app

# Add corporate CA so npm/Node work behind the proxy
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*
COPY certs/corporate-ca.crt /usr/local/share/ca-certificates/corporate-ca.crt
RUN chmod 644 /usr/local/share/ca-certificates/corporate-ca.crt && update-ca-certificates

# Install Node deps and build Svelte frontend from *this* repo
COPY package.json package-lock.json ./
RUN npm ci --force

COPY . .
ENV APP_BUILD_HASH=${BUILD_HASH}
RUN npm run build

######## Runtime: extend official Open WebUI image ########
FROM ghcr.io/open-webui/open-webui:main

# Keep /app as working directory while copying assets
WORKDIR /app

# Add corporate CA inside runtime image as well (for HF/pip/etc. at runtime)
COPY certs/corporate-ca.crt /usr/local/share/ca-certificates/corporate-ca.crt
RUN chmod 644 /usr/local/share/ca-certificates/corporate-ca.crt && update-ca-certificates || true

# Overwrite the built frontend with your custom build
COPY --from=build /app/build ./build

# Overwrite backend code with your fork (folders/filetree changes, etc.)
COPY backend ./backend

# Ensure backend is the working directory and explicitly run start.sh there
WORKDIR /app
CMD ["bash", "backend/start.sh"]

