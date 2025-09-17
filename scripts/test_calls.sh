#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../.env" 2>/dev/null || true
set -x
curl -i "https://$REGION-$PROJECT_ID.cloudfunctions.net/o11y-bq-costs" || true
curl -i "https://$REGION-$PROJECT_ID.cloudfunctions.net/o11y-bq-costs-services" || true
