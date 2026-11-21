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

Nav order: Chart, Schedule, Actions, Configuration.

- **ChartPage** — Front page. ApexCharts chart of moisture readings, pump actions and daily ET0 (`/api/sensor`, `/api/pump`, `/api/schedule`), with a day/week/month toggle.
- **ActionPage** — Buttons to trigger pump start/stop and force a measurement. Each uses `ActionButton` to PUT to the backend.
- **ConfigPage** — Form to view/edit runtime configuration (measurement/pump/valve, plus irrigation planning: `pump_seconds_per_mm`, plan/window times). Fetches from and PUTs to `/api/configuration/1`.
- **SchedulePage** — Wraps `ScheduleEditor`. The editor shows today's ET0 (`/api/schedule?start=&end=`) and lists/adds/edits/deletes today's pending pump actions via `/api/scheduled-pump`.

### Key Component: ActionButton

Reusable button that sends a PUT request to a given URL (with optional JSON body via `requestData`). Shows loading spinner, success checkmark, or error cross with 5-second auto-dismiss.

### Key Component: TimeInput

24-hour `HH:MM` text input used for all time fields. The native `<input type="time">` shows AM/PM on phones with a 12h locale, so it isn't used.

### Dependencies

- **axios** — HTTP client (base URL set globally)
- **vue3-apexcharts** / **apexcharts** — charting (loaded async, excluded from Vite dep optimization)
- **moment-timezone** — date handling for chart time ranges
- **@lucide/vue** — icons
- **vue-router** — client-side routing

## System Overview

Pflaenzli is split across three sibling repos under `../` (`pflaenzli_arduino`, `pflaenzli_backend`, `pflaenzli_frontend`). Each has its own CLAUDE.md; this section is kept identical in all three.

```
browser ──HTTPS──▶ nginx (basic auth) ──/api/──▶ backend (gunicorn :8000) ◀── cron: POST /internal/tick (every minute)
                                                    │                ▲
                     PUT /configuration,            │                │  GET /api/configuration/1 (boot, retried until success)
                     PUT /pump/start|stop,          ▼                │  POST /api/sensor   (each reading)
                     PUT /triggerMeasurement     Arduino (HTTP :80) ─┘  POST /api/pump     (each pump on/off)
```

- **Backend is the hub.** The frontend talks only to the backend (never to the Arduino). The backend pushes commands to the Arduino, and the Arduino reports back to the backend.
- **Scheduling lives in the backend.** The minutely tick plans the day once (Open-Meteo ET0 → number of pump events spread over the watering window) and fires due events by sending `pump/start` to the Arduino. The Arduino knows nothing about schedules: each start runs one cycle (open valve, wait `valve_duration`, pump for `pump_duration`, close both). Automatic moisture measurements run on the Arduino's own timer (`measurement_interval`).
- **`PumpAction` rows reflect the real pump state.** They are only created when the Arduino reports via `POST /api/pump`. Manual starts and scheduled starts only relay the command.
- **Shared contract:** the JSON config fields `measurement_interval`, `pump_duration`, `valve_duration`, `measurement_enabled`, `pump_enabled` are used by all three repos, so renaming one touches all three. The irrigation fields (`pump_seconds_per_mm`, `calc_time`, `window_start`, `window_end`) are used only by the backend and frontend.
- **Monitoring:** each tick reports to healthchecks.io (dead-man's switch: stale moisture readings, scheduled starts the Arduino never confirmed).
- **Production** runs on a Raspberry Pi on the LAN: nginx serves the built frontend and proxies `/api/` to the gunicorn systemd service. `/internal/` is not proxied. Deploys are pull-based: push `main` to GitHub, then `git pull` on the Pi. The repos are public, so IPs, coordinates and secrets stay in gitignored files (`arduino_secrets.h`, backend `.env`, frontend `.env.production`).
