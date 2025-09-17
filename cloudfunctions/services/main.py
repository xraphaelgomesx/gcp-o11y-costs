import os, json, time
from google.cloud import bigquery
import requests

METRIC_NAME = os.getenv("METRIC_NAME", "gcp.cost.service.usd")
SFX_REALM = os.getenv("SFX_REALM", "us1")
SFX_TOKEN = os.getenv("SFX_TOKEN")
BQ_VIEW_SERVICE = os.getenv("BQ_VIEW_SERVICE")    # project.dataset.v_cost_by_service_24h
WINDOW_LABEL = os.getenv("WINDOW_LABEL", "24h")

def _resp(msg, code=200): return (msg, code, {"Content-Type": "text/plain"})

def entry_point(request):
    if not BQ_VIEW_SERVICE: return _resp("BQ_VIEW_SERVICE not set", 500)
    if not SFX_TOKEN: return _resp("SFX_TOKEN not set", 500)

    client = bigquery.Client()
    q = f"""
    SELECT project_id, service_name AS service, location, ROUND(SUM(value), 6) AS usd
    FROM `{BQ_VIEW_SERVICE}`
    WHERE usage_date = CURRENT_DATE()
    GROUP BY 1,2,3
    ORDER BY usd DESC
    LIMIT 500
    """
    rows = list(client.query(q))

    datapoints = []
    ts = int(time.time() * 1000)
    for r in rows:
        dp = {
            "metric": METRIC_NAME,
            "value": float(r['usd']),
            "dimensions": {
                "project_id": r['project_id'],
                "service": r['service'],
                "location": r['location'],
                "window": WINDOW_LABEL
            },
            "timestamp": ts
        }
        datapoints.append(dp)

    url = f"https://ingest.{SFX_REALM}.signalfx.com/v2/datapoint"
    headers = {"X-SF-TOKEN": SFX_TOKEN, "Content-Type": "application/json"}
    payload = {"gauge": datapoints}
    r = requests.post(url, headers=headers, data=json.dumps(payload), timeout=20)
    if r.status_code >= 300:
        return _resp(f"ingest failed: {r.status_code} {r.text}", 502)
    return _resp("OK")
