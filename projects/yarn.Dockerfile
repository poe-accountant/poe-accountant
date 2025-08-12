# syntax=docker/dockerfile:1.7
ARG NODE_VERSION=22-alpine
ARG WORKSPACE=ninja-server

FROM node:${NODE_VERSION} AS base
RUN corepack enable && corepack prepare yarn@stable --activate

# Build all projects
FROM base AS base-fs
WORKDIR /app

COPY . .

# Dev dependencies
FROM base-fs AS dev-fs
RUN yarn install

FROM dev-fs as build
RUN yarn build

# Testing
FROM dev-fs AS test
RUN yarn test

# Prod dependencies
FROM base-fs AS prod-fs
ENV NODE_ENV=production
RUN yarn install
RUN --mount=type=bind,from=build,source=/app,target=/app-build \
  cd /app-build && cp -r --parents projects/*/dist /app

# Final Build
FROM prod-fs AS final
ARG WORKSPACE

WORKDIR /app/projects/${WORKSPACE}

CMD [ "yarn", "start:prod" ]

