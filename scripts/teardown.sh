#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../.env" 2>/dev/null || true
gcloud scheduler jobs delete o11y-bq-costs-hourly --location "$REGION" --project "$PROJECT_ID" -q || true
gcloud scheduler jobs delete o11y-bq-costs-services-hourly --location "$REGION" --project "$PROJECT_ID" -q || true
gcloud functions delete o11y-bq-costs --gen2 --region "$REGION" --project "$PROJECT_ID" -q || true
gcloud functions delete o11y-bq-costs-services --gen2 --region "$REGION" --project "$PROJECT_ID" -q || true
