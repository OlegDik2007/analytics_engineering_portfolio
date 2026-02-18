# performance / explain notes

Not gonna lie, most perf issues come from the big boy table: `location_events`.

### Usual filters
- created_at >= now() - interval '7 days'
- session_id = '...'
- visitor_id = '...'
- event_name IN (...)

### Indexes used
- BTREE: (session_id, created_at), (event_name, created_at), (visitor_id, created_at)
- BRIN: created_at for big range scans (cheap index, big win)

### Example
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT event_name, count(*)
FROM public.location_events
WHERE created_at >= now() - interval '30 days'
GROUP BY 1
ORDER BY 2 DESC;
