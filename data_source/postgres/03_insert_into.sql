COPY customer(customer_id, name, email, country, age, signup_date, marketing_opt_in)
FROM '/kaggle_dataset/customers.csv'
DELIMITER ',' CSV HEADER;

COPY product(product_id, category, name, price_usd, cost_usd, margin_usd)
FROM '/kaggle_dataset/products.csv'
DELIMITER ',' CSV HEADER;


COPY orders(order_id, customer_id, order_time, payment_method, discount_pct, subtotal_usd, total_usd)
FROM '/kaggle_dataset/orders.csv'
DELIMITER ',' CSV HEADER;


COPY order_item(order_id, product_id, unit_price_usd, quantity, line_total_usd)
FROM '/kaggle_dataset/order_items.csv'
DELIMITER ',' CSV HEADER;


COPY review(review_id, order_id, product_id, rating, review_text, review_time)
FROM '/kaggle_dataset/reviews.csv'
DELIMITER ',' CSV HEADER;