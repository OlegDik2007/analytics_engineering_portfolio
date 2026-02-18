-- db/constraints.sql
-- constraints + a few checks. not overthinking it.

BEGIN;

-- basic status checks (edit list later if you need)
ALTER TABLE public.services
  ADD CONSTRAINT IF NOT EXISTS chk_services_status
  CHECK (status IN ('active','draft','paused','archived'));

ALTER TABLE public.bookings
  ADD CONSTRAINT IF NOT EXISTS chk_bookings_status
  CHECK (status IS NULL OR status IN ('new','pending','confirmed','cancelled','completed'));

ALTER TABLE public.service_analytics
  ADD CONSTRAINT IF NOT EXISTS chk_service_analytics_action
  CHECK (action_type IS NULL OR action_type IN ('view','view_details','contact_agent','share','bookmark'));

-- data sanity
ALTER TABLE public.location_events
  ADD CONSTRAINT IF NOT EXISTS chk_location_lat
  CHECK (latitude IS NULL OR (latitude >= -90 AND latitude <= 90));

ALTER TABLE public.location_events
  ADD CONSTRAINT IF NOT EXISTS chk_location_lon
  CHECK (longitude IS NULL OR (longitude >= -180 AND longitude <= 180));

ALTER TABLE public.location_events
  ADD CONSTRAINT IF NOT EXISTS chk_location_accuracy
  CHECK (accuracy IS NULL OR accuracy >= 0);

-- relationships 
-- visitor_id is not always known at ingestion time, so no FK forced here.
-- If you want: create visitor_tracking first + backfill, then enable.
-- ALTER TABLE public.location_events
--   ADD CONSTRAINT fk_location_events_visitor
--   FOREIGN KEY (visitor_id) REFERENCES public.visitor_tracking(visitor_id);

COMMIT;
