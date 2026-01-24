-- streaming
CREATE TABLE IF NOT EXISTS idk.`tracking.web.events.local` ON CLUSTER 'cluster_1S_2R' (
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
ORDER BY (session_id, event_id, event_timestamp, product_id)
PARTITION BY toStartOfInterval(event_timestamp, INTERVAL 30 MINUTE)
TTL event_timestamp + INTERVAL 31 MINUTE
SETTINGS ttl_only_drop_parts = 1;

-- streaming
CREATE TABLE IF NOT EXISTS idk.`tracking.web.events`
ON CLUSTER cluster_1S_2R
ENGINE = Distributed('cluster_1S_2R', 'idk', 'tracking.web.events.local', rand());


-- 
CREATE TABLE IF NOT EXISTS idk.`db.public.customer.local` ON CLUSTER 'cluster_1S_2R' (
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

CREATE TABLE IF NOT EXISTS idk.`db.public.customer` ON CLUSTER cluster_1S_2R
ENGINE = Distributed('cluster_1S_2R', 'idk', 'db.public.customer.local', rand());


CREATE TABLE IF NOT EXISTS idk.`db.public.product.local` ON CLUSTER 'cluster_1S_2R' (
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

CREATE TABLE IF NOT EXISTS idk.`db.public.product` ON CLUSTER cluster_1S_2R
ENGINE = Distributed('cluster_1S_2R', 'idk', 'db.public.product.local', rand());


CREATE TABLE IF NOT EXISTS idk.`db.public.order.local` ON CLUSTER 'cluster_1S_2R' (
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
ORDER BY (customer_id);

CREATE TABLE IF NOT EXISTS idk.`db.public.order` ON CLUSTER cluster_1S_2R
ENGINE = Distributed('cluster_1S_2R', 'idk', 'db.public.order.local', rand());



CREATE TABLE IF NOT EXISTS idk.`db.public.order_item.local` ON CLUSTER 'cluster_1S_2R' (
    order_item_id UInt64,
    order_id UInt64,
    product_id UInt64,
    unit_price_usd Decimal(10, 2),
    quantity Int32,
    line_total_usd Decimal(10, 2),
    __op String
) 
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{database}/{table}/{shard}', '{replica}')
ORDER BY (order_id);

CREATE TABLE IF NOT EXISTS idk.`db.public.order_item` ON CLUSTER cluster_1S_2R
ENGINE = Distributed('cluster_1S_2R', 'idk', 'db.public.order_item.local', rand());


CREATE TABLE IF NOT EXISTS idk.`db.public.review.local` ON CLUSTER 'cluster_1S_2R' (
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

CREATE TABLE IF NOT EXISTS idk.`db.public.review` ON CLUSTER cluster_1S_2R
ENGINE = Distributed('cluster_1S_2R', 'idk', 'db.public.review.local', rand());

----------------------------------------------
-- Table Common
WITH latest_event_per_session AS (
    SELECT
        *
    FROM idk.`tracking.web.events`
    WHERE toStartOfMinute(event_timestamp) >= toStartOfMinute(now() - INTERVAL 30 MINUTE)
    ORDER BY session_id ASC, event_id DESC
    LIMIT 1 BY session_id
)

----------------------------------------------
-- Social Proof
SELECT
    product_id,
    count(
        CASE WHEN event_type = 'page_view' THEN 1
            ELSE 0
        END
    ) AS total_viewer,
    count(
        CASE WHEN event_type = 'add_to_cart' THEN 1
            ELSE 0
        END
    ) AS total_add_to_cart,
FROM latest_event_per_session
WHERE event_type IN ('page_view', 'add_to_cart')
GROUP BY product_id;

----------------------------------------------
-- Sản phẩm Hot
ORDER BY total_add_to_cart DESC, total_viewer DESC;

----------------------------------------------
-- Active Funnel
SELECT
    event_type,
    count(event_type) AS total
FROM latest_event_per_session
GROUP BY event_type;

----------------------------------------------
-- Phát hiện gian lận/Lỗi hệ thống
WITH warning_purchase AS (
    SELECT
        session_id,
        max(customer_id) AS sync_customer_id
    FROM latest_event_per_session
    WHERE 1 = 1
        AND event_type = 'purchase'
        AND toStartOfMinute(event_timestamp) >= toStartOfMinute(now() - INTERVAL 2 MINUTE)
    GROUP BY session_id
    HAVING count(session_id) > 3
)
SELECT
    c.*
FROM customer AS c
INNER JOIN warning_purchase AS wp
    ON c.customer_id = wp.customer_id;

----------------------------------------------
-- Common1
WITH current_order_id AS (
    SELECT
        order_id
    FROM order
    WHERE toStartOfMinute(order_time) >= toStartOfMinute(now() - INTERVAL 10 MINUTE)
),
top_current_purchase_product AS (
    SELECT
        product_id,
        sum(quantity) AS total
    FROM order_item AS oi
    INNER JOIN current_order_id AS coi
        ON oi.order_id = coi.order_id
    GROUP BY product_id
)

----------------------------------------------
-- Top sản phẩm đc bán nhiều nhất
SELECT
    *
FROM top_current_purchase_product
ORDER BY total DESC
LIMIT 10;

----------------------------------------------
-- Top sản phẩm đc bán nhiều nhất cho từng danh mục
SELECT
    p.category,
    tp.product_id,
    tp.total
FROM top_current_purchase_product AS tp
INNER JOIN product AS p
    ON p.product_id = tp.product_id
ORDER BY total DESC
LIMIT 10 BY p.category;

--------------------BATCHING------------------
----------------------------------------------
-- Doanh Thu
SELECT
    sum(total_usd) AS revenue,
    sum(subtotal_usd) AS revenue_after_disct
FROM order;

----------------------------------------------
-- batch common
WITH most_sell_product AS (
    SELECT
        oi.product_id,
        p.name,
        p.category,
        sum(oi.quantity) AS total
    FROM order_item AS oi
    INNER JOIN product AS p
        ON oi.product_id = p.product_id
    GROUP BY oi.product_id, p.name, p.category
)

----------------------------------------------
-- Top sản phẩm đc bán nhiều nhất
SELECT
    product_id,
    name,
    total
FROM most_sell_product
ORDER BY total;

----------------------------------------------
-- Top sản phẩm đc bán nhiều nhất cho từng danh mục
SELECT
    product_id,
    name,
    category,
    total
FROM most_sell_product
LIMIT 10 BY category;

----------------------------------------------
-- Top khách hàng mua nhiều nhất trong tháng
SELECT
    o.customer_id,
    sum(o.total_usd) AS total
FROM customer AS c
INNER JOIN order AS o
    ON c.customer_id = c.customer_id
WHERE o.order_time >= DATE_TRUNC('month', CURRENT_DATE())
GROUP BY o.customer_id
ORDER BY total DESC;

----------------------------------------------
-- Top khách hàng mua nhiều nhất trong tuần
SELECT
    o.customer_id,
    sum(o.total_usd) AS total
FROM customer AS c
INNER JOIN order AS o
    ON c.customer_id = c.customer_id
WHERE o.order_time >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY o.customer_id
ORDER BY total DESC;

----------------------------------------------
-- Top khách hàng mua nhiều nhất trong khoảng thời gian bất kỳ (sẽ đc BI trigger manually)
start_dt = 
end_dt = 
SELECT
    o.customer_id,
    sum(o.total_usd) AS total
FROM customer AS c
INNER JOIN order AS o
    ON c.customer_id = c.customer_id
WHERE o.order_time BETWEEN start_dt AND end_dt
GROUP BY o.customer_id
ORDER BY total DESC;

----------------------------------------------
-- Top sản phẩm được đánh giá thấp nhất
SELECT
    product_id,
    avg(rating) AS rate
FROM review
GROUP BY product_id
HAVING rate < 4
ORDER BY rate ASC
LIMIT 10;

----------------------------------------------
-- Top khách hàng mua nhiều là từ country nào để tạo chiến dịch tương ứng
SELECT
    c.country,
    count(c.customer_id) AS total
FROM order AS o
INNER JOIN customer AS c
    ON o.customer_id = c.customer_id
GROUP BY c.country;