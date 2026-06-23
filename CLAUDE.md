# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Pflaenzli Frontend is a Vue 3 single-page app that displays plant moisture/pump data as charts and provides controls to manage the Arduino watering system. It talks to the Django backend (`pflaenzli_backend`) REST API.

## Development Commands

```bash
# Install dependencies
npm install

# Dev server with hot reload
npm run dev

# Production build
npm run build

# Preview production build
npm run preview

# Deploy to server (builds, copies to /var/www, reloads nginx)
./deploy.sh
```

No tests or linting tools are configured.

## API Configuration

The backend API URL is set via environment variable `VITE_API_URL`:
- Development: `http://localhost:8000/api/` (in `.env.development`)
- Production: configured in `.env.production` with the server URL behind nginx reverse proxy

`axios.defaults.baseURL` is set globally in `main.js` from this variable.

## Architecture

Vue 3 + Vite app using Options API. Router uses `createMemoryHistory` (no URL path changes in browser).

### Pages (in `src/components/`)

- **ChartPage** — Front page. Shows an ApexCharts line/scatter chart of moisture/pump data (last month, with day/week/month toggle) and the `ScheduleEditor` for today's actions.
- **ActionPage** — Buttons to trigger pump start/stop and force a measurement. Each uses `ActionButton` to PUT to the backend.
- **ConfigPage** — Form to view/edit runtime configuration (measurement/pump/valve, plus irrigation planning: `pump_seconds_per_mm`, plan/window times, lat/lon). Fetches from and PUTs to `/api/configuration/1`.
- **ScheduleEditor** — Lists/adds/edits(time)/deletes today's scheduled pump actions via `/api/schedule`.

### Key Component: ActionButton

Reusable button that sends a PUT request to a given URL (with optional JSON body via `requestData`). Shows loading spinner, success checkmark, or error cross with 5-second auto-dismiss.

### Dependencies

- **axios** — HTTP client (base URL set globally)
- **vue3-apexcharts** / **apexcharts** — charting (loaded async, excluded from Vite dep optimization)
- **moment-timezone** — date handling for chart time ranges
- **vue-router** — client-side routing

## Related Projects

- **pflaenzli_backend** — Django REST API (sibling directory, runs on port 8000)
- **pflaenzli_arduino** — Arduino firmware (sibling directory)
