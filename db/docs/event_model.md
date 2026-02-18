# Event model

### location_events (big)
Columns are split in 3 groups:

**Identity**
- visitor_id
- user_email (optional)
- session_id

**Context**
- country/state/city, lat/lon
- ip_address (inet)
- user_agent, referrer, page_url

**Event**
- event_name (page_view, view_details, contact_agent...)
- event_type (track, etc)
- event_props (jsonb) for stuff that changes a lot (utm, service_id, etc)

Tip: store timestamps in UTC (timestamptz). Makes life easier later.
