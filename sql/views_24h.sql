-- View 1: Costs per instance (Compute Engine) — 24h
CREATE OR REPLACE VIEW `${PROJECT_ID}.${DATASET}.v_cost_by_instance_24h` AS
SELECT
  DATE(CURRENT_TIMESTAMP()) AS usage_date,
  'gcp.cost.usd' AS metric_name,
  SUM(cost) AS value,
  CAST(UNIX_MILLIS(CURRENT_TIMESTAMP()) AS INT64) AS timestamp,
  project.id AS project_id,
  service.description AS service_name,
  COALESCE(REGEXP_EXTRACT(resource.global_name, r'/instances/([^/]+)$'), resource.name, '(unknown)') AS instance_ref,
  location.location AS location,
  ANY_VALUE(currency) AS currency
FROM `${BQ_TABLE}`
WHERE _PARTITIONDATE BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY) AND CURRENT_DATE()
  AND export_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
  AND service.description = 'Compute Engine'
  AND cost_type = 'regular'
GROUP BY 1,2,4,5,6,7,8;

-- View 2: Costs per service — 24h
CREATE OR REPLACE VIEW `${PROJECT_ID}.${DATASET}.v_cost_by_service_24h` AS
SELECT
  DATE(CURRENT_TIMESTAMP()) AS usage_date,
  'gcp.cost.service.usd' AS metric_name,
  SUM(cost) AS value,
  CAST(UNIX_MILLIS(CURRENT_TIMESTAMP()) AS INT64) AS timestamp,
  project.id AS project_id,
  service.description AS service_name,
  '(all)' AS instance_ref,
  location.location AS location,
  ANY_VALUE(currency) AS currency
FROM `${BQ_TABLE}`
WHERE _PARTITIONDATE BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY) AND CURRENT_DATE()
  AND export_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
  AND cost_type = 'regular'
GROUP BY 1,2,4,5,6,7,8;
