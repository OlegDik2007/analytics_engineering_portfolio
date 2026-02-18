-- analytics/funnels.sql
-- example funnel (session based)

WITH s AS (
  SELECT
    session_id,
    bool_or(event_name = 'page_view') AS page_view,
    bool_or(event_name = 'view_details') AS view_details,
    bool_or(event_name = 'contact_agent') AS contact_agent
  FROM public.location_events
  WHERE created_at >= now() - interval '30 days'
    AND session_id IS NOT NULL
  GROUP BY session_id
)
SELECT
  COUNT(*) AS sessions,
  COUNT(*) FILTER (WHERE page_view) AS step1_page_view,
  COUNT(*) FILTER (WHERE page_view AND view_details) AS step2_view_details,
  COUNT(*) FILTER (WHERE page_view AND view_details AND contact_agent) AS step3_contact_agent
FROM s;

-- Funnel conversion rates (rough)
WITH s AS (
  SELECT
    session_id,
    bool_or(event_name = 'page_view') AS page_view,
    bool_or(event_name = 'view_details') AS view_details,
    bool_or(event_name = 'contact_agent') AS contact_agent
  FROM public.location_events
  WHERE created_at >= now() - interval '30 days'
    AND session_id IS NOT NULL
  GROUP BY session_id
),
agg AS (
  SELECT
    COUNT(*) AS sessions,
    COUNT(*) FILTER (WHERE page_view) AS p,
    COUNT(*) FILTER (WHERE page_view AND view_details) AS d,
    COUNT(*) FILTER (WHERE page_view AND view_details AND contact_agent) AS c
  FROM s
)
SELECT
  sessions,
  p, d, c,
  ROUND((d::numeric / NULLIF(p,0))*100, 2) AS pct_view_to_details,
  ROUND((c::numeric / NULLIF(d,0))*100, 2) AS pct_details_to_contact
FROM agg;
