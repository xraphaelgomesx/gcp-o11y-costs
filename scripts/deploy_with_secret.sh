#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../.env" 2>/dev/null || true
SECRET_NAME="sfx-token"
if [[ -n "${SFX_TOKEN:-}" ]]; then
  echo -n "$SFX_TOKEN" | gcloud secrets create "$SECRET_NAME" --data-file=- --replication-policy="automatic" --project "$PROJECT_ID" || true
fi

gcloud functions deploy o11y-bq-costs   --gen2 --runtime python312 --region "$REGION" --project "$PROJECT_ID"   --entry-point entry_point --trigger-http --allow-unauthenticated   --service-account "$SERVICE_ACCOUNT"   --set-env-vars BQ_TABLE="$BQ_TABLE",SFX_REALM="$SFX_REALM",WINDOW_MINUTES="$WINDOW_MINUTES",WINDOW_LABEL="$WINDOW_LABEL",METRIC_NAME="gcp.cost.usd"   --set-secrets SFX_TOKEN=$SECRET_NAME:latest   --source ./cloudfunctions/instance

gcloud functions deploy o11y-bq-costs-services   --gen2 --runtime python312 --region "$REGION" --project "$PROJECT_ID"   --entry-point entry_point --trigger-http --allow-unauthenticated   --service-account "$SERVICE_ACCOUNT"   --set-env-vars BQ_VIEW_SERVICE="$PROJECT_ID.$DATASET.v_cost_by_service_24h",SFX_REALM="$SFX_REALM",WINDOW_LABEL="$WINDOW_LABEL",METRIC_NAME="gcp.cost.service.usd"   --set-secrets SFX_TOKEN=$SECRET_NAME:latest   --source ./cloudfunctions/services
