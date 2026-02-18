-- analytics/retention.sql
-- simple retention: first_seen day cohort, returning visitors by day+7, day+14

WITH first_seen AS (
  SELECT
    visitor_id,
    MIN(date_trunc('day', created_at)) AS cohort_day
  FROM public.location_events
  WHERE visitor_id IS NOT NULL
  GROUP BY visitor_id
),
activity AS (
  SELECT
    visitor_id,
    date_trunc('day', created_at) AS active_day
  FROM public.location_events
  WHERE visitor_id IS NOT NULL
  GROUP BY 1,2
),
joined AS (
  SELECT
    f.cohort_day,
    a.visitor_id,
    (a.active_day - f.cohort_day) AS delta
  FROM first_seen f
  JOIN activity a ON a.visitor_id = f.visitor_id
)
SELECT
  cohort_day,
  COUNT(DISTINCT visitor_id) AS cohort_size,
  COUNT(DISTINCT visitor_id) FILTER (WHERE delta = interval '7 days')  AS retained_d7,
  COUNT(DISTINCT visitor_id) FILTER (WHERE delta = interval '14 days') AS retained_d14
FROM joined
GROUP BY cohort_day
ORDER BY cohort_day;
