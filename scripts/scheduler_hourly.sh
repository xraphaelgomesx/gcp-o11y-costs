#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../.env" 2>/dev/null || true
gcloud scheduler jobs create http o11y-bq-costs-hourly   --project="$PROJECT_ID" --location="$REGION"   --schedule="0 * * * *" --time-zone="${TIMEZONE:-UTC}"   --http-method=GET   --uri="https://$REGION-$PROJECT_ID.cloudfunctions.net/o11y-bq-costs"   --oidc-service-account-email="$SERVICE_ACCOUNT" || true

gcloud scheduler jobs create http o11y-bq-costs-services-hourly   --project="$PROJECT_ID" --location="$REGION"   --schedule="0 * * * *" --time-zone="${TIMEZONE:-UTC}"   --http-method=GET   --uri="https://$REGION-$PROJECT_ID.cloudfunctions.net/o11y-bq-costs-services"   --oidc-service-account-email="$SERVICE_ACCOUNT" || true
