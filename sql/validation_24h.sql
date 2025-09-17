-- Validation: per instance (24h)
SELECT
  project.id AS project_id,
  COALESCE(REGEXP_EXTRACT(resource.global_name, r'/instances/([^/]+)$'), resource.name, '(unknown)') AS instance_name,
  ROUND(SUM(cost), 6) AS cost_usd_24h
FROM `${BQ_TABLE}`
WHERE _PARTITIONDATE BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY) AND CURRENT_DATE()
  AND export_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
  AND service.description = 'Compute Engine'
  AND cost_type = 'regular'
GROUP BY 1,2
ORDER BY cost_usd_24h DESC;

-- Validation: per service (24h)
SELECT
  project.id AS project_id,
  service.description AS service,
  location.location AS region,
  ROUND(SUM(cost), 6) AS cost_usd_24h
FROM `${BQ_TABLE}`
WHERE _PARTITIONDATE BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY) AND CURRENT_DATE()
  AND export_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
  AND cost_type = 'regular'
GROUP BY 1,2,3
ORDER BY cost_usd_24h DESC;
