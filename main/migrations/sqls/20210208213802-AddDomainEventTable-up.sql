/* Replace with your SQL commands */
CREATE TABLE domain_event
(
    id uuid NOT NULL PRIMARY KEY,
    payload jsonb NOT NULL,
    status varchar NOT NULL,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL
);
CREATE INDEX event_status_idx ON domain_event (status);
CREATE INDEX event_pyld_idx ON domain_event USING GIN (payload jsonb_path_ops);