# GCP → Splunk Observability (Costs 24h)

**Working generic pack** to export **GCP Billing (rolling 24h)** to **Splunk Observability**.

- Cloud Functions (Python): `cloudfunctions/instance` (per instance), `cloudfunctions/services` (per service)
- Scripts: `scripts/` (bootstrap, render SQL, deploy, scheduler, teardown)
- SQL: `sql/views_24h.sql`, `sql/validation_24h.sql`
- Example env: `.env.example` (placeholders only)
- SignalFlow: `SignalFlow.md`

#Highlevel Architecture:
<img width="1536" height="1024" alt="ChatGPT Image Sep 17, 2025, 04_51_16 PM" src="https://github.com/user-attachments/assets/1fbe4a8e-92a6-4764-b08d-d34c46345524" />

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

#This is the expected result at Splunk Observability Cloud
<img width="1612" height="942" alt="Screenshot 2025-08-15 at 15 20 41" src="https://github.com/user-attachments/assets/df5c2ce0-08db-4353-b95f-9315ce04c22a" />
