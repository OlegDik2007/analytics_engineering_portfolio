-- analytics/kpis.sql
-- quick KPI queries you can demo in README or interview.

-- DAU / unique sessions last N days
SELECT
  date_trunc('day', created_at) AS day,
  COUNT(DISTINCT visitor_id) FILTER (WHERE visitor_id IS NOT NULL) AS dau_visitors,
  COUNT(DISTINCT session_id) FILTER (WHERE session_id IS NOT NULL) AS dau_sessions,
  COUNT(*) AS events
FROM public.location_events
WHERE created_at >= now() - interval '14 days'
GROUP BY 1
ORDER BY 1;

-- Top pages
SELECT
  page_url,
  COUNT(*) AS events,
  COUNT(DISTINCT visitor_id) AS uniq_visitors
FROM public.location_events
WHERE created_at >= now() - interval '7 days'
GROUP BY 1
ORDER BY events DESC
LIMIT 25;

-- Event mix
SELECT
  event_name,
  COUNT(*) AS events
FROM public.location_events
WHERE created_at >= now() - interval '30 days'
GROUP BY 1
ORDER BY events DESC;
