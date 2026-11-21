# Changelog

Breaking changes are listed first in each entry.

## 2.0.67-1 (2026-11-21)

- README only: the Deploy on Railway button now links to the published code `mermaid-live-edito-1`. Railway assigned that code at publishing; the old `mermaid-live-editor-1` link answered 404. No change to the image, build or variables.

## 2.0.67 (2026-11-21)

- First release of the Railway template.
- Mermaid Live Editor 2.0.67, built from upstream commit `d040b02bf717c3dadcefd11d6e0278ea94f33c11` (2026-11-18).
- Build stage `node:26.13.1-trixie-slim@sha256:e6bedef2…8820bc`, runtime `nginx:1.30.7-alpine@sha256:caf4e1e0…3a97e3`.
- nginx listens on `PORT` (default 8080) with a `/healthz` health check.
