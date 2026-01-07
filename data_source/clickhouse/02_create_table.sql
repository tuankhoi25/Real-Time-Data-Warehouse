CREATE TABLE idk.`tracking.web.events` ON CLUSTER 'cluster_2S_2R' (
    event_id UInt64,
    session_id UInt64,
    event_timestamp DateTime,
    event_type String,
    product_id Nullable(Float64),
    qty Nullable(Float64),
    cart_size Nullable(Float64),
    payment Nullable(String),
    discount_pct Nullable(Float64),
    amount_usd Nullable(Float64),
    customer_id UInt64,
    session_start_time DateTime,
    device LowCardinality(String),
    source LowCardinality(String),
    country FixedString(2)
) 
ENGINE = MergeTree()
ORDER BY (event_timestamp, event_id);