-- db/rollups.sql
-- daily rollups. materialized views keep things simple.

BEGIN;

-- Daily pageviews by geo
CREATE MATERIALIZED VIEW IF NOT EXISTS public.mv_daily_pageviews_geo AS
SELECT
  date_trunc('day', created_at) AS day,
  COALESCE(country, 'Unknown') AS country,
  COALESCE(state, 'Unknown')   AS state,
  COALESCE(city, 'Unknown')    AS city,
  COALESCE(page_url, 'Unknown') AS page_url,
  COUNT(*) AS events,
  COUNT(DISTINCT visitor_id) FILTER (WHERE visitor_id IS NOT NULL) AS uniq_visitors,
  COUNT(DISTINCT session_id) FILTER (WHERE session_id IS NOT NULL) AS uniq_sessions
FROM public.location_events
GROUP BY 1,2,3,4,5;

CREATE INDEX IF NOT EXISTS idx_mv_daily_pageviews_geo_day
ON public.mv_daily_pageviews_geo (day);

-- Daily events by event_name
CREATE MATERIALIZED VIEW IF NOT EXISTS public.mv_daily_events AS
SELECT
  date_trunc('day', created_at) AS day,
  event_name,
  COUNT(*) AS events,
  COUNT(DISTINCT visitor_id) FILTER (WHERE visitor_id IS NOT NULL) AS uniq_visitors,
  COUNT(DISTINCT session_id) FILTER (WHERE session_id IS NOT NULL) AS uniq_sessions
FROM public.location_events
GROUP BY 1,2;

CREATE INDEX IF NOT EXISTS idx_mv_daily_events_day_event
ON public.mv_daily_events (day, event_name);

-- Service action rollup (for “view details”, “contact agent”, etc.)
CREATE MATERIALIZED VIEW IF NOT EXISTS public.mv_daily_service_actions AS
SELECT
  date_trunc('day', clicked_at) AS day,
  service_id,
  agent_id,
  action_type,
  COUNT(*) AS actions
FROM public.service_analytics
GROUP BY 1,2,3,4;

CREATE INDEX IF NOT EXISTS idx_mv_daily_service_actions_day
ON public.mv_daily_service_actions (day);

-- Convenience summary table (simple example)
CREATE TABLE IF NOT EXISTS public.agent_analytics_summary (
  agent_id bigint,
  total_services bigint,
  total_actions bigint,
  last_action_at timestamptz,
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- refresh helper (run daily via cron / job)
-- NOTE: Postgres needs manual REFRESH; in prod you'd schedule it.
-- REFRESH MATERIALIZED VIEW CONCURRENTLY needs unique index; keeping normal refresh for simplicity.
-- REFRESH MATERIALIZED VIEW public.mv_daily_pageviews_geo;
-- REFRESH MATERIALIZED VIEW public.mv_daily_events;
-- REFRESH MATERIALIZED VIEW public.mv_daily_service_actions;

COMMIT;
