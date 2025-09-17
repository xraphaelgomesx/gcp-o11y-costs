#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../.env" 2>/dev/null || true
gcloud services enable cloudfunctions.googleapis.com run.googleapis.com   artifactregistry.googleapis.com cloudbuild.googleapis.com   bigquery.googleapis.com cloudscheduler.googleapis.com secretmanager.googleapis.com   --project "$PROJECT_ID" || true

gcloud iam service-accounts create o11y-bq-sender   --project "$PROJECT_ID" --display-name "O11y BQ Sender" || true

gcloud projects add-iam-policy-binding "$PROJECT_ID"   --member="serviceAccount:$SERVICE_ACCOUNT" --role="roles/bigquery.dataViewer" || true

gcloud projects add-iam-policy-binding "$PROJECT_ID"   --member="serviceAccount:$SERVICE_ACCOUNT" --role="roles/bigquery.jobUser" || true
