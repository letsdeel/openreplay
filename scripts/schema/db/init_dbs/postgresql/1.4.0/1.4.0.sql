BEGIN;
CREATE OR REPLACE FUNCTION openreplay_version()
    RETURNS text AS
$$
SELECT 'v1.4.0'
$$ LANGUAGE sql IMMUTABLE;

CREATE INDEX IF NOT EXISTS user_favorite_sessions_user_id_session_id_idx ON public.user_favorite_sessions (user_id, session_id);

CREATE INDEX IF NOT EXISTS pages_session_id_timestamp_idx ON events.pages (session_id, timestamp);

CREATE INDEX IF NOT EXISTS errors_timestamp_idx ON events.errors (timestamp);
CREATE INDEX IF NOT EXISTS projects_project_key_idx ON public.projects (project_key);

ALTER TABLE sessions
    ADD COLUMN IF NOT EXISTS utm_source   text NULL DEFAULT NULL,
    ADD COLUMN IF NOT EXISTS utm_medium   text NULL DEFAULT NULL,
    ADD COLUMN IF NOT EXISTS utm_campaign text NULL DEFAULT NULL;

CREATE INDEX IF NOT EXISTS sessions_utm_source_gin_idx ON public.sessions USING GIN (utm_source gin_trgm_ops);
CREATE INDEX IF NOT EXISTS sessions_utm_medium_gin_idx ON public.sessions USING GIN (utm_medium gin_trgm_ops);
CREATE INDEX IF NOT EXISTS sessions_utm_campaign_gin_idx ON public.sessions USING GIN (utm_campaign gin_trgm_ops);
CREATE INDEX IF NOT EXISTS requests_timestamp_session_id_failed_idx ON events_common.requests (timestamp, session_id) WHERE success = FALSE;


DROP INDEX IF EXISTS sessions_project_id_user_browser_idx1;
DROP INDEX IF EXISTS sessions_project_id_user_country_idx1;
ALTER INDEX IF EXISTS platform_idx RENAME TO sessions_platform_idx;
ALTER INDEX IF EXISTS events.resources_duration_idx RENAME TO resources_duration_durationgt0_idx;
DROP INDEX IF EXISTS projects_project_key_idx1;
CREATE INDEX IF NOT EXISTS errors_parent_error_id_idx ON public.errors (parent_error_id);

CREATE INDEX IF NOT EXISTS performance_session_id_idx ON events.performance (session_id);
CREATE INDEX IF NOT EXISTS performance_timestamp_idx ON events.performance (timestamp);
CREATE INDEX IF NOT EXISTS performance_session_id_timestamp_idx ON events.performance (session_id, timestamp);
CREATE INDEX IF NOT EXISTS performance_avg_cpu_gt0_idx ON events.performance (avg_cpu) WHERE avg_cpu > 0;
CREATE INDEX IF NOT EXISTS performance_avg_used_js_heap_size_gt0_idx ON events.performance (avg_used_js_heap_size) WHERE avg_used_js_heap_size > 0;

CREATE TABLE IF NOT EXISTS public.metrics
(
    metric_id  integer generated BY DEFAULT AS IDENTITY PRIMARY KEY,
    project_id integer NOT NULL REFERENCES public.projects (project_id) ON DELETE CASCADE,
    user_id    integer REFERENCES public.users (user_id) ON DELETE SET NULL,
    name       text    NOT NULL,
    is_public  boolean NOT NULL DEFAULT FALSE,
    created_at timestamp        default timezone('utc'::text, now()) not null,
    deleted_at timestamp
);
CREATE INDEX IF NOT EXISTS metrics_user_id_is_public_idx ON public.metrics (user_id, is_public);
CREATE TABLE IF NOT EXISTS public.metric_series
(
    series_id  integer generated BY DEFAULT AS IDENTITY PRIMARY KEY,
    metric_id  integer REFERENCES public.metrics (metric_id) ON DELETE CASCADE,
    index      integer                                        NOT NULL,
    name       text                                           NULL,
    filter     jsonb                                          NOT NULL,
    created_at timestamp DEFAULT timezone('utc'::text, now()) NOT NULL,
    deleted_at timestamp
);
CREATE INDEX IF NOT EXISTS metric_series_metric_id_idx ON public.metric_series (metric_id);

CREATE INDEX IF NOT EXISTS funnels_project_id_idx ON public.funnels (project_id);


CREATE TABLE IF NOT EXISTS public.searches
(
    search_id  integer generated BY DEFAULT AS IDENTITY PRIMARY KEY,
    project_id integer NOT NULL REFERENCES public.projects (project_id) ON DELETE CASCADE,
    user_id    integer NOT NULL REFERENCES public.users (user_id) ON DELETE CASCADE,
    name       text    not null,
    filter     jsonb   not null,
    created_at timestamp        default timezone('utc'::text, now()) not null,
    deleted_at timestamp,
    is_public  boolean NOT NULL DEFAULT False
);

CREATE INDEX IF NOT EXISTS searches_user_id_is_public_idx ON public.searches (user_id, is_public);
CREATE INDEX IF NOT EXISTS searches_project_id_idx ON public.searches (project_id);
CREATE INDEX IF NOT EXISTS alerts_project_id_idx ON alerts (project_id);

ALTER TABLE alerts
    ADD COLUMN IF NOT EXISTS series_id integer NULL REFERENCES public.metric_series (series_id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS alerts_series_id_idx ON alerts (series_id);
UPDATE alerts
SET options=jsonb_set(options, '{change}', '"change"')
WHERE detection_method = 'change'
  AND options -> 'change' ISNULL;
COMMIT;