import os, json, time
from google.cloud import bigquery
import requests

METRIC_NAME = os.getenv("METRIC_NAME", "gcp.cost.usd")
SFX_REALM = os.getenv("SFX_REALM", "us1")
SFX_TOKEN = os.getenv("SFX_TOKEN")
BQ_TABLE = os.getenv("BQ_TABLE")             # project.dataset.table
WINDOW_MINUTES = int(os.getenv("WINDOW_MINUTES", "1440"))
WINDOW_LABEL = os.getenv("WINDOW_LABEL", "24h")

def _resp(msg, code=200): return (msg, code, {"Content-Type": "text/plain"})

def entry_point(request):
    if not BQ_TABLE: return _resp("BQ_TABLE not set", 500)
    if not SFX_TOKEN: return _resp("SFX_TOKEN not set", 500)

    client = bigquery.Client()
    q = f"""
    SELECT
      project.id AS project_id,
      COALESCE(REGEXP_EXTRACT(resource.global_name, r'/instances/([^/]+)$'),
               resource.name, '(unknown)') AS instance_name,
      location.location AS location,
      ROUND(SUM(cost), 6) AS usd
    FROM `{BQ_TABLE}`
    WHERE _PARTITIONDATE BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY) AND CURRENT_DATE()
      AND export_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL @window MINUTE)
      AND service.description = 'Compute Engine'
      AND cost_type = 'regular'
    GROUP BY 1,2,3
    ORDER BY usd DESC
    LIMIT 500
    """
    job = client.query(q, job_config=bigquery.QueryJobConfig(
        query_parameters=[bigquery.ScalarQueryParameter("window", "INT64", WINDOW_MINUTES)]
    ))
    rows = list(job)

    datapoints = []
    ts = int(time.time() * 1000)
    for r in rows:
        dp = {
            "metric": METRIC_NAME,
            "value": float(r['usd']),
            "dimensions": {
                "project_id": r['project_id'],
                "instance_name": r['instance_name'],
                "service": "Compute Engine",
                "location": r['location'],
                "window": WINDOW_LABEL
            },
            "timestamp": ts
        }
        datapoints.append(dp)

    # Ingest
    url = f"https://ingest.{SFX_REALM}.signalfx.com/v2/datapoint"
    headers = {"X-SF-TOKEN": SFX_TOKEN, "Content-Type": "application/json"}
    payload = {"gauge": datapoints}
    r = requests.post(url, headers=headers, data=json.dumps(payload), timeout=20)
    if r.status_code >= 300:
        return _resp(f"ingest failed: {r.status_code} {r.text}", 502)
    return _resp("OK")
