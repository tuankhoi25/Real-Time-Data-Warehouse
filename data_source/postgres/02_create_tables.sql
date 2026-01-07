CREATE TABLE IF NOT EXISTS customer (
    customer_id BIGSERIAL PRIMARY KEY,
    name TEXT,
    email TEXT,
    country CHAR(2),
    age INT,
    signup_date TIMESTAMP,
    marketing_opt_in BOOL
);

CREATE TABLE IF NOT EXISTS orders (
    order_id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT REFERENCES customer(customer_id),
    order_time TIMESTAMP,
    payment_method TEXT,
    discount_pct DECIMAL(10, 2),
    subtotal_usd DECIMAL(10, 2),
    total_usd DECIMAL(10, 2)
);

CREATE TABLE IF NOT EXISTS product (
    product_id BIGSERIAL PRIMARY KEY,
    category TEXT,
    name TEXT,
    price_usd DECIMAL(10, 2),
    cost_usd DECIMAL(10, 2),
    margin_usd DECIMAL(10, 2)
);

CREATE TABLE IF NOT EXISTS order_item (
    order_item_id BIGSERIAL PRIMARY KEY,
    order_id BIGINT REFERENCES orders(order_id),
    product_id BIGINT REFERENCES product(product_id),
    unit_price_usd DECIMAL(10, 2),
    quantity INT,
    line_total_usd DECIMAL(10, 2)
);

CREATE TABLE IF NOT EXISTS review (
    review_id BIGSERIAL PRIMARY KEY,
    order_id BIGINT REFERENCES orders(order_id),
    product_id BIGINT REFERENCES product(product_id),
    rating INT,
    review_text TEXT,
    review_time TIMESTAMP
);