-- analytics/geo.sql
-- geo breakdown, super common for travel sites.

SELECT
  COALESCE(country,'Unknown') AS country,
  COALESCE(state,'Unknown')   AS state,
  COALESCE(city,'Unknown')    AS city,
  COUNT(*) AS events,
  COUNT(DISTINCT visitor_id) FILTER (WHERE visitor_id IS NOT NULL) AS uniq_visitors
FROM public.location_events
WHERE created_at >= now() - interval '30 days'
GROUP BY 1,2,3
ORDER BY events DESC
LIMIT 50;
