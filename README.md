[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/mermaid-live-editor-1?utm_medium=integration&utm_source=button&utm_campaign=mermaid-live-editor)

# Mermaid Live Editor on Railway

One-click Railway template for [Mermaid Live Editor](https://github.com/mermaid-js/mermaid-live-editor) (MIT), the browser editor behind [mermaid.live](https://mermaid.live): write Mermaid diagram code, see the diagram as you type, then share a link or export PNG/SVG.

## What it deploys

| Service | Source | Notes |
|---|---|---|
| `Mermaid Live Editor` | this repo (`Dockerfile`) | Static site built from upstream commit [`d040b02`](https://github.com/mermaid-js/mermaid-live-editor/commit/d040b02bf717c3dadcefd11d6e0278ea94f33c11) (live editor 2.0.67, released 2026-11-18), served by nginx on Railway's `PORT`; health check `/healthz`; public Railway domain |

- **Pinned build.** Upstream publishes no version tags, only moving `latest`/`nightly` images, so this repo builds the site itself from a pinned upstream commit, using `node:26.13.1-trixie-slim` and `nginx:1.30.7-alpine`, both pinned by digest. A build takes about 1.5 minutes.
- **No database and no volume, on purpose.** Diagrams live in the visitor's browser: in the page URL (`#pako:…`) and in local storage for history. The server only serves the static app, so a redeploy loses nothing. Keep a diagram by bookmarking or sharing its URL, or by exporting it.
- **No login and no secrets.** There is no admin UI and no server-side account. The editor is public to anyone with the URL, which only lets them use the editor.

## Variables

| Variable | Default | What it does |
|---|---|---|
| `PORT` | `8080` | Port nginx listens on; the public domain targets it. |

Optional build-time settings (add one as a service variable, then redeploy, because Vite bakes them into the site): `MERMAID_RENDERER_URL` (PNG/SVG links, default `https://mermaid.ink`; empty turns them off), `MERMAID_KROKI_RENDERER_URL` (default `https://kroki.io`), `MERMAID_IS_ENABLED_MERMAID_CHART_LINKS` (`true`/`false`), `MERMAID_ANALYTICS_URL` (Plausible URL, off by default), `MERMAID_PRIVACY_POLICY_URL` and `MERMAID_HIDE_PRIVACY_POLICY`.

Diagram rendering and the editor itself run in the browser. The "PNG/SVG link" and Kroki actions call those public services from the visitor's browser; point them at your own [mermaid.ink](https://github.com/jihchi/mermaid.ink) or [Kroki](https://kroki.io) to keep everything self-hosted.

## Updates

The service builds from this repo's `main` branch. When we bump the pinned upstream commit here, Railway shows deployers an "update available" notice and they choose when to apply it. Every change is listed in [CHANGELOG.md](CHANGELOG.md), breaking changes first.

## Run locally

```sh
docker compose up --build
# open http://localhost:8080 (health: http://localhost:8080/healthz)
```

## Licence

Mermaid Live Editor is © its authors under the MIT licence (see [LICENSE](LICENSE)). This wrapper (Dockerfile and nginx config) is published under the same licence.
