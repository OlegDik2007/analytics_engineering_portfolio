-- db/seed.sql
-- minimal seed, just to run queries. not trying to be perfect.

BEGIN;

INSERT INTO public.users (email, name)
VALUES
  ('oleg@example.com', 'Oleg'),
  ('client1@example.com', 'Client One')
ON CONFLICT (email) DO NOTHING;

INSERT INTO public.agents (user_id, company_name, email, verification_status)
SELECT u.id, 'Avide Travel', 'agent@avide.travel', 'verified'
FROM public.users u
WHERE u.email = 'oleg@example.com'
ON CONFLICT DO NOTHING;

INSERT INTO public.services (agent_id, title, status, start_date, end_date, family_friendly, place_image_google_urls)
SELECT a.id, 'Punta Cana Family Deal', 'active', '2026-03-10', '2026-03-15', true, '["https://example.com/img1.jpg"]'::jsonb
FROM public.agents a
WHERE a.email = 'agent@avide.travel'
ON CONFLICT DO NOTHING;

-- a few events
INSERT INTO public.location_events (
  visitor_id, user_email, country, state, city,
  latitude, longitude, timezone, accuracy, ip_address,
  method, event_type, session_id, page_url, user_agent, referrer,
  event_name, event_props, created_at
)
VALUES
  ('v_001', 'client1@example.com', 'US', 'IL', 'Chicag',
   41.6986, -88.0684, 'America/Chicago', 10, '1.1.1.1',
   'GET', 'track', 's_001', '/services/1', 'Mozilla', 'google',
   'page_view', '{"utm":"google","campaign":"test"}'::jsonb, now() - interval '2 days'),

  ('v_001', 'client1@example.com', 'US', 'IL', 'Chicago',
   41.6986, -88.0684, 'America/Chicago', 10, '1.1.1.1',
   'GET', 'track', 's_001', '/services/1', 'Mozilla', 'google',
   'view_details', '{"service_id":"1"}'::jsonb, now() - interval '2 days' + interval '2 minutes'),

  ('v_001', 'client1@example.com', 'US', 'IL', 'Chicago',
   41.6986, -88.0684, 'America/Chicago', 10, '1.1.1.1',
   'POST', 'track', 's_001', '/services/1', 'Mozilla', 'google',
   'contact_agent', '{"service_id":"1","channel":"web"}'::jsonb, now() - interval '2 days' + interval '5 minutes');

-- service analytics
INSERT INTO public.service_analytics (service_id, agent_id, action_type, clicked_at, meta)
SELECT s.id, s.agent_id, 'view_details', now() - interval '2 days', '{"source":"web"}'::jsonb
FROM public.services s
LIMIT 1;

COMMIT;
