-- Query 1: Product Reordering Rates by Department and Aisle
SELECT 
    d.department,
    a.aisle,
    COUNT(op.product_id) AS total_orders,
    SUM(op.reordered) AS reorder_count,
    ROUND(SUM(op.reordered) * 1.0 / COUNT(op.product_id), 4) AS reorder_rate
FROM order_products__prior op
JOIN products p ON op.product_id = p.product_id
JOIN aisles a ON p.aisle_id = a.aisle_id
JOIN departments d ON p.department_id = d.department_id
GROUP BY d.department, a.aisle
ORDER BY reorder_rate DESC;

-- Query 2: Order Distribution by Day of Week and Hour
SELECT 
    order_dow,
    order_hour_of_day,
    COUNT(order_id) AS order_count,
    ROUND(COUNT(order_id) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage
FROM orders
GROUP BY order_dow, order_hour_of_day
ORDER BY order_dow, order_hour_of_day;

-- Query 3: Impact of Days Since Prior Order on Basket Size
SELECT 
    CASE 
        WHEN days_since_prior_order IS NULL THEN 'First Order'
        WHEN days_since_prior_order < 7 THEN 'Less than a week'
        WHEN days_since_prior_order < 14 THEN '1-2 weeks'
        WHEN days_since_prior_order < 21 THEN '2-3 weeks'
        WHEN days_since_prior_order < 28 THEN '3-4 weeks'
        ELSE 'More than 4 weeks'
    END AS order_interval,
    COUNT(DISTINCT o.order_id) AS num_orders,
    ROUND(AVG(basket_size), 2) AS avg_basket_size,
    ROUND(AVG(reorder_ratio), 4) AS avg_reorder_ratio
FROM orders o
JOIN (
    SELECT 
        order_id, 
        COUNT(product_id) AS basket_size,
        SUM(reordered) * 1.0 / COUNT(product_id) AS reorder_ratio
    FROM order_products__prior
    GROUP BY order_id
) bs ON o.order_id = bs.order_id
GROUP BY order_interval
ORDER BY 
    CASE order_interval
        WHEN 'First Order' THEN 0
        WHEN 'Less than a week' THEN 1
        WHEN '1-2 weeks' THEN 2
        WHEN '2-3 weeks' THEN 3
        WHEN '3-4 weeks' THEN 4
        ELSE 5
    END;

-- Query 4: Frequently Co-purchased Products
WITH product_pairs AS (
    SELECT 
        a.product_id AS product_1,
        b.product_id AS product_2,
        COUNT(*) AS pair_count
    FROM order_products__prior a
    JOIN order_products__prior b ON a.order_id = b.order_id AND a.product_id < b.product_id
    GROUP BY a.product_id, b.product_id
    HAVING COUNT(*) > 100
)
SELECT 
    p1.product_name AS product_1_name,
    p2.product_name AS product_2_name,
    pp.pair_count
FROM product_pairs pp
JOIN products p1 ON pp.product_1 = p1.product_id
JOIN products p2 ON pp.product_2 = p2.product_id
ORDER BY pp.pair_count DESC
LIMIT 20;

-- Query 5: Customer Segmentation by Shopping Behavior
WITH user_metrics AS (
    SELECT 
        o.user_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        AVG(basket.basket_size) AS avg_basket_size,
        AVG(basket.reorder_ratio) AS avg_reorder_ratio,
        AVG(o.days_since_prior_order) AS avg_days_between_orders,
        SUM(CASE WHEN o.order_dow IN (0, 6) THEN 1 ELSE 0 END) * 1.0 / 
            COUNT(o.order_id) AS weekend_order_ratio
    FROM orders o
    JOIN (
        SELECT 
            order_id,
            COUNT(product_id) AS basket_size,
            SUM(reordered) * 1.0 / COUNT(product_id) AS reorder_ratio
        FROM order_products__prior
        GROUP BY order_id
    ) basket ON o.order_id = basket.order_id
    WHERE o.eval_set = 'prior'
    GROUP BY o.user_id
    HAVING COUNT(DISTINCT o.order_id) >= 5
)
SELECT 
    CASE 
        WHEN avg_basket_size <= 5 THEN 'Small Basket'
        WHEN avg_basket_size <= 12 THEN 'Medium Basket'
        ELSE 'Large Basket'
    END AS basket_segment,
    CASE 
        WHEN avg_days_between_orders <= 7 THEN 'Frequent Shopper'
        WHEN avg_days_between_orders <= 14 THEN 'Regular Shopper'
        ELSE 'Occasional Shopper'
    END AS frequency_segment,
    CASE 
        WHEN avg_reorder_ratio <= 0.3 THEN 'Low Reorder'
        WHEN avg_reorder_ratio <= 0.6 THEN 'Medium Reorder'
        ELSE 'High Reorder'
    END AS reorder_segment,
    COUNT(*) AS user_count,
    ROUND(AVG(total_orders), 1) AS avg_orders,
    ROUND(AVG(avg_basket_size), 1) AS avg_items_per_order,
    ROUND(AVG(avg_reorder_ratio), 3) AS avg_reorder_rate,
    ROUND(AVG(avg_days_between_orders), 1) AS avg_days_between_orders,
    ROUND(AVG(weekend_order_ratio), 3) AS weekend_order_rate
FROM user_metrics
GROUP BY basket_segment, frequency_segment, reorder_segment
ORDER BY user_count DESC;