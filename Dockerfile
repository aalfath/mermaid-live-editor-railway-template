# Mermaid Live Editor packaged for Railway.
#
# Upstream publishes only moving `latest`/`nightly` images (no version tags), so this
# Dockerfile builds the static site itself from a pinned upstream commit, with the build
# and runtime images pinned by version and digest. To update: change MLE_COMMIT (and
# MLE_VERSION) to a newer commit on upstream's `master` branch, then add a CHANGELOG entry.
ARG MLE_VERSION=2.0.67
ARG MLE_COMMIT=d040b02bf717c3dadcefd11d6e0278ea94f33c11

FROM node:26.13.1-trixie-slim@sha256:e6bedef217677b276c591795e169840edd9096dbf13f29df8ef8d1856b8820bc AS build
ARG MLE_COMMIT

# Same build tools as upstream's own Dockerfile (native modules need them), on Debian.
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates git g++ make python3 \
 && rm -rf /var/lib/apt/lists/* \
 && npm install -g corepack@0.36.0 \
 && corepack enable pnpm

ENV CI=true \
    COREPACK_ENABLE_DOWNLOAD_PROMPT=0 \
    NODE_OPTIONS=--max-old-space-size=3072

WORKDIR /app
# A commit SHA is content-addressed, so this always fetches exactly the pinned source.
RUN git init -q . \
 && git remote add origin https://github.com/mermaid-js/mermaid-live-editor.git \
 && git fetch -q --depth 1 origin "$MLE_COMMIT" \
 && git checkout -q FETCH_HEAD

RUN pnpm install --frozen-lockfile

# Optional build-time settings (Vite bakes them into the site). Unset means upstream's
# defaults from its .env file: mermaid.ink for PNG/SVG links, kroki.io for the Kroki link,
# Mermaid Chart links on, no analytics. Set one as a Railway variable and redeploy to change it.
ARG MERMAID_RENDERER_URL
ARG MERMAID_KROKI_RENDERER_URL
ARG MERMAID_ANALYTICS_URL
ARG MERMAID_DOMAIN
ARG MERMAID_IS_ENABLED_MERMAID_CHART_LINKS
ARG MERMAID_PRIVACY_POLICY_URL
ARG MERMAID_HIDE_PRIVACY_POLICY

RUN pnpm build

FROM nginx:1.30.7-alpine@sha256:caf4e1e032a20f9c3c5e28fc7f25ffd768ad8677b4975c54193075997b3a97e3
ARG MLE_VERSION
ARG MLE_COMMIT
LABEL org.opencontainers.image.title="Mermaid Live Editor (Railway template)" \
      org.opencontainers.image.version="$MLE_VERSION" \
      org.opencontainers.image.revision="$MLE_COMMIT" \
      org.opencontainers.image.source="https://github.com/aalfath/mermaid-live-editor-railway-template"

# Railway sends traffic and health checks to $PORT. The nginx entrypoint renders
# /etc/nginx/templates/*.template with envsubst at start, so the port is read at runtime.
ENV PORT=8080
COPY default.conf.template /etc/nginx/templates/default.conf.template
COPY --from=build /app/docs /usr/share/nginx/html

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
