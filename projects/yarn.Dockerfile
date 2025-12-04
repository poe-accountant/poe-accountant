# syntax=docker/dockerfile:1.7
ARG NODE_VERSION=22-alpine
ARG WORKSPACE

FROM node:${NODE_VERSION} AS base
RUN corepack enable && corepack prepare yarn@stable --activate

USER node
WORKDIR /home/node/app


# Build all projects
FROM base AS base-fs
COPY --chown=node:node . .

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
RUN yarn workspaces focus --all --production

RUN --mount=type=bind,from=build,source=/home/node/app,target=/app-build \
  cd /app-build && cp -r --parents projects/*/dist /home/node/app

# Final Build
FROM prod-fs AS final
ARG WORKSPACE

WORKDIR /home/node/app/projects/${WORKSPACE}

CMD [ "yarn", "start:prod" ]

