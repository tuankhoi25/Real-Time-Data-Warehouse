CREATE TABLE IF NOT EXISTS idk.`tracking.web.events.local` ON CLUSTER 'cluster_2S_2R' (
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
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{database}/{table}/{shard}', '{replica}')
ORDER BY (event_timestamp, event_id);

CREATE TABLE IF NOT EXISTS idk.`tracking.web.events`
ON CLUSTER cluster_2S_2R
ENGINE = Distributed('cluster_2S_2R', 'idk', 'tracking.web.events.local', rand());



CREATE TABLE IF NOT EXISTS idk.`db.public.customer.local` ON CLUSTER 'cluster_2S_2R' (
    customer_id UInt64,
    name String,
    email String,
    country FixedString(2),
    age Int32,
    signup_date DateTime,
    marketing_opt_in Bool,
    __op String
) 
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{database}/{table}/{shard}', '{replica}')
ORDER BY (customer_id);

CREATE TABLE IF NOT EXISTS idk.`db.public.customer` ON CLUSTER cluster_2S_2R
ENGINE = Distributed('cluster_2S_2R', 'idk', 'db.public.customer.local', rand());


CREATE TABLE IF NOT EXISTS idk.`db.public.product.local` ON CLUSTER 'cluster_2S_2R' (
    product_id UInt64,
    category String,
    name String,
    price_usd Decimal(10, 2),
    cost_usd Decimal(10, 2),
    margin_usd Decimal(10, 2),
    __op String
) 
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{database}/{table}/{shard}', '{replica}')
ORDER BY (product_id);

CREATE TABLE IF NOT EXISTS idk.`db.public.product` ON CLUSTER cluster_2S_2R
ENGINE = Distributed('cluster_2S_2R', 'idk', 'db.public.product.local', rand());


CREATE TABLE IF NOT EXISTS idk.`db.public.orders.local` ON CLUSTER 'cluster_2S_2R' (
    order_id UInt64,
    customer_id UInt64,
    order_time DateTime,
    payment_method String,
    discount_pct Decimal(10, 2),
    subtotal_usd Decimal(10, 2),
    total_usd Decimal(10, 2),
    __op String
) 
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{database}/{table}/{shard}', '{replica}')
ORDER BY (order_time, order_id);

CREATE TABLE IF NOT EXISTS idk.`db.public.orders` ON CLUSTER cluster_2S_2R
ENGINE = Distributed('cluster_2S_2R', 'idk', 'db.public.orders.local', rand());



CREATE TABLE IF NOT EXISTS idk.`db.public.order_item.local` ON CLUSTER 'cluster_2S_2R' (
    order_item_id UInt64,
    order_id UInt64,
    product_id UInt64,
    unit_price_usd Decimal(10, 2),
    quantity Int32,
    line_total_usd Decimal(10, 2),
    __op String
) 
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{database}/{table}/{shard}', '{replica}')
ORDER BY (order_id, order_item_id);

CREATE TABLE IF NOT EXISTS idk.`db.public.order_item` ON CLUSTER cluster_2S_2R
ENGINE = Distributed('cluster_2S_2R', 'idk', 'db.public.order_item.local', rand());


CREATE TABLE IF NOT EXISTS idk.`db.public.review.local` ON CLUSTER 'cluster_2S_2R' (
    review_id UInt64,
    order_id UInt64,
    product_id UInt64,
    rating Int32,
    review_text String,
    review_time DateTime,
    __op String
) 
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{database}/{table}/{shard}', '{replica}')
ORDER BY (review_time, review_id);

CREATE TABLE IF NOT EXISTS idk.`db.public.review` ON CLUSTER cluster_2S_2R
ENGINE = Distributed('cluster_2S_2R', 'idk', 'db.public.review.local', rand());