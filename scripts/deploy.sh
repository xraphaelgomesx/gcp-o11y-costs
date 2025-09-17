#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../.env" 2>/dev/null || true
gcloud functions deploy o11y-bq-costs   --gen2 --runtime python312 --region "$REGION" --project "$PROJECT_ID"   --entry-point entry_point --trigger-http --allow-unauthenticated   --service-account "$SERVICE_ACCOUNT"   --set-env-vars BQ_TABLE="$BQ_TABLE",SFX_REALM="$SFX_REALM",WINDOW_MINUTES="$WINDOW_MINUTES",WINDOW_LABEL="$WINDOW_LABEL",METRIC_NAME="gcp.cost.usd",SFX_TOKEN="$SFX_TOKEN"   --source ./cloudfunctions/instance

gcloud functions deploy o11y-bq-costs-services   --gen2 --runtime python312 --region "$REGION" --project "$PROJECT_ID"   --entry-point entry_point --trigger-http --allow-unauthenticated   --service-account "$SERVICE_ACCOUNT"   --set-env-vars BQ_VIEW_SERVICE="$PROJECT_ID.$DATASET.v_cost_by_service_24h",SFX_REALM="$SFX_REALM",WINDOW_LABEL="$WINDOW_LABEL",METRIC_NAME="gcp.cost.service.usd",SFX_TOKEN="$SFX_TOKEN"   --source ./cloudfunctions/services
