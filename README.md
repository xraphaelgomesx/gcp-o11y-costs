# GCP → Splunk Observability (Costs 24h)

**Working generic pack** to export **GCP Billing (rolling 24h)** to **Splunk Observability**.

- Cloud Functions (Python): `cloudfunctions/instance` (per instance), `cloudfunctions/services` (per service)
- Scripts: `scripts/` (bootstrap, render SQL, deploy, scheduler, teardown)
- SQL: `sql/views_24h.sql`, `sql/validation_24h.sql`
- Example env: `.env.example` (placeholders only)
- SignalFlow: `SignalFlow.md`

## Quickstart
```bash
cp .env.example .env   # fill placeholders
chmod +x scripts/*.sh
./scripts/bootstrap.sh
./scripts/render_sql.sh
./scripts/deploy.sh            # or ./scripts/deploy_with_secret.sh
./scripts/test_calls.sh
./scripts/scheduler_hourly.sh
```
> Do **NOT** commit secrets (.env).
