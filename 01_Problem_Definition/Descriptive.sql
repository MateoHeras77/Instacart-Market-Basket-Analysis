-- Descriptive.sql: Comprehensive descriptive queries for all Instacart database tables
-- Author: GitHub Copilot
-- Date: May 20, 2025

-- ********************************************************************************
-- TABLE: aisles
-- Description: Contains information about store aisles
-- ********************************************************************************

-- Get basic information about the aisles table
SELECT 
    'aisles' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT aisle_id) AS unique_aisle_ids,
    COUNT(DISTINCT aisle) AS unique_aisle_names
FROM aisles;

-- List all aisles with their IDs, sorted by aisle ID
SELECT 
    aisle_id,
    aisle,
    (SELECT COUNT(*) FROM products p WHERE p.aisle_id = a.aisle_id) AS product_count
FROM aisles a
ORDER BY aisle_id;

-- Find top 10 aisles with the most products
SELECT 
    a.aisle_id,
    a.aisle,
    COUNT(p.product_id) AS product_count
FROM aisles a
JOIN products p ON a.aisle_id = p.aisle_id
GROUP BY a.aisle_id, a.aisle
ORDER BY product_count DESC
LIMIT 10;

-- Find top 10 aisles with the most ordered products
SELECT 
    a.aisle_id,
    a.aisle,
    COUNT(DISTINCT op.product_id) AS unique_products_ordered,
    COUNT(op.product_id) AS total_products_ordered,
    SUM(op.reordered) AS total_reordered_products,
    ROUND(SUM(op.reordered) * 1.0 / COUNT(op.product_id), 4) AS reorder_rate
FROM aisles a
JOIN products p ON a.aisle_id = p.aisle_id
JOIN order_products__prior op ON p.product_id = op.product_id
GROUP BY a.aisle_id, a.aisle
ORDER BY total_products_ordered DESC
LIMIT 10;

-- ********************************************************************************
-- TABLE: departments
-- Description: Contains information about store departments
-- ********************************************************************************

-- Get basic information about the departments table
SELECT 
    'departments' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT department_id) AS unique_department_ids,
    COUNT(DISTINCT department) AS unique_department_names
FROM departments;

-- List all departments with their IDs, sorted by department ID
SELECT 
    department_id,
    department,
    (SELECT COUNT(*) FROM products p WHERE p.department_id = d.department_id) AS product_count,
    (SELECT COUNT(DISTINCT aisle_id) FROM products p WHERE p.department_id = d.department_id) AS aisle_count
FROM departments d
ORDER BY department_id;

-- Find departments with the most products
SELECT 
    d.department_id,
    d.department,
    COUNT(p.product_id) AS product_count,
    COUNT(DISTINCT p.aisle_id) AS unique_aisles
FROM departments d
JOIN products p ON d.department_id = p.department_id
GROUP BY d.department_id, d.department
ORDER BY product_count DESC;

-- Department performance analysis (orders, reorders, etc.)
SELECT 
    d.department_id,
    d.department,
    COUNT(DISTINCT op.order_id) AS total_orders,
    COUNT(op.product_id) AS total_products_ordered,
    SUM(op.reordered) AS total_reordered_products,
    ROUND(SUM(op.reordered) * 1.0 / COUNT(op.product_id), 4) AS reorder_rate
FROM departments d
JOIN products p ON d.department_id = p.department_id
JOIN order_products__prior op ON p.product_id = op.product_id
GROUP BY d.department_id, d.department
ORDER BY total_products_ordered DESC;

-- ********************************************************************************
-- TABLE: products
-- Description: Contains information about products available in the store
-- ********************************************************************************

-- Get basic information about the products table
SELECT 
    'products' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_id) AS unique_product_ids,
    COUNT(DISTINCT product_name) AS unique_product_names,
    COUNT(DISTINCT aisle_id) AS unique_aisles,
    COUNT(DISTINCT department_id) AS unique_departments
FROM products;

-- List product count by department and aisle
SELECT 
    d.department,
    a.aisle,
    COUNT(p.product_id) AS product_count
FROM products p
JOIN aisles a ON p.aisle_id = a.aisle_id
JOIN departments d ON p.department_id = d.department_id
GROUP BY d.department, a.aisle
ORDER BY d.department, product_count DESC;

-- Top 20 most frequently ordered products
SELECT 
    p.product_id,
    p.product_name,
    d.department,
    a.aisle,
    COUNT(op.order_id) AS order_count,
    SUM(op.reordered) AS reorder_count,
    ROUND(SUM(op.reordered) * 1.0 / COUNT(op.product_id), 4) AS reorder_rate
FROM products p
JOIN order_products__prior op ON p.product_id = op.product_id
JOIN aisles a ON p.aisle_id = a.aisle_id
JOIN departments d ON p.department_id = d.department_id
GROUP BY p.product_id, p.product_name, d.department, a.aisle
ORDER BY order_count DESC
LIMIT 20;

-- Products with the highest reorder rate (minimum 100 orders)
SELECT 
    p.product_id,
    p.product_name,
    d.department,
    a.aisle,
    COUNT(op.order_id) AS order_count,
    SUM(op.reordered) AS reorder_count,
    ROUND(SUM(op.reordered) * 1.0 / COUNT(op.product_id), 4) AS reorder_rate
FROM products p
JOIN order_products__prior op ON p.product_id = op.product_id
JOIN aisles a ON p.aisle_id = a.aisle_id
JOIN departments d ON p.department_id = d.department_id
GROUP BY p.product_id, p.product_name, d.department, a.aisle
HAVING COUNT(op.order_id) >= 100
ORDER BY reorder_rate DESC
LIMIT 20;

-- Products with the lowest reorder rate (minimum 100 orders)
SELECT 
    p.product_id,
    p.product_name,
    d.department,
    a.aisle,
    COUNT(op.order_id) AS order_count,
    SUM(op.reordered) AS reorder_count,
    ROUND(SUM(op.reordered) * 1.0 / COUNT(op.product_id), 4) AS reorder_rate
FROM products p
JOIN order_products__prior op ON p.product_id = op.product_id
JOIN aisles a ON p.aisle_id = a.aisle_id
JOIN departments d ON p.department_id = d.department_id
GROUP BY p.product_id, p.product_name, d.department, a.aisle
HAVING COUNT(op.order_id) >= 100
ORDER BY reorder_rate ASC
LIMIT 20;

-- ********************************************************************************
-- TABLE: orders
-- Description: Contains information about customer orders
-- ********************************************************************************

-- Get basic information about the orders table
SELECT 
    'orders' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_order_ids,
    COUNT(DISTINCT user_id) AS unique_users,
    COUNT(DISTINCT eval_set) AS eval_set_count
FROM orders;

-- Orders breakdown by evaluation set
SELECT 
    eval_set,
    COUNT(*) AS order_count,
    COUNT(DISTINCT user_id) AS user_count,
    MIN(order_number) AS min_order_number,
    MAX(order_number) AS max_order_number,
    AVG(order_number) AS avg_order_number
FROM orders
GROUP BY eval_set;

-- Order distribution by day of week and hour
SELECT 
    order_dow AS day_of_week,
    order_hour_of_day AS hour_of_day,
    COUNT(order_id) AS order_count,
    ROUND(COUNT(order_id) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage_of_total
FROM orders
GROUP BY order_dow, order_hour_of_day
ORDER BY order_dow, order_hour_of_day;

-- Order patterns by day of week
SELECT 
    order_dow AS day_of_week,
    COUNT(order_id) AS order_count,
    ROUND(COUNT(order_id) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage_of_total,
    AVG(order_hour_of_day) AS avg_hour_of_day,
    COUNT(DISTINCT user_id) AS unique_users
FROM orders
GROUP BY order_dow
ORDER BY order_dow;

-- Number of orders by hour of day
SELECT 
    order_hour_of_day AS hour_of_day,
    COUNT(order_id) AS order_count,
    ROUND(COUNT(order_id) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage_of_total
FROM orders
GROUP BY order_hour_of_day
ORDER BY order_hour_of_day;

-- Distribution of days since prior order
SELECT 
    days_since_prior_order,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders WHERE days_since_prior_order IS NOT NULL), 2) AS percentage_of_total
FROM orders
WHERE days_since_prior_order IS NOT NULL
GROUP BY days_since_prior_order
ORDER BY days_since_prior_order;

-- Users by number of orders
SELECT 
    order_count_bucket,
    COUNT(*) AS user_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT user_id) FROM orders), 2) AS percentage_of_users
FROM (
    SELECT 
        user_id,
        CASE 
            WHEN COUNT(*) = 1 THEN '1 order'
            WHEN COUNT(*) = 2 THEN '2 orders'
            WHEN COUNT(*) = 3 THEN '3 orders'
            WHEN COUNT(*) = 4 THEN '4 orders'
            WHEN COUNT(*) BETWEEN 5 AND 10 THEN '5-10 orders'
            WHEN COUNT(*) BETWEEN 11 AND 20 THEN '11-20 orders'
            ELSE 'More than 20 orders'
        END AS order_count_bucket
    FROM orders
    GROUP BY user_id
) user_counts
GROUP BY order_count_bucket
ORDER BY 
    CASE order_count_bucket
        WHEN '1 order' THEN 1
        WHEN '2 orders' THEN 2
        WHEN '3 orders' THEN 3
        WHEN '4 orders' THEN 4
        WHEN '5-10 orders' THEN 5
        WHEN '11-20 orders' THEN 6
        ELSE 7
    END;

-- Impact of days since prior order on reordering
WITH order_reorder_stats AS (
    SELECT 
        o.order_id,
        o.days_since_prior_order,
        COUNT(op.product_id) AS basket_size,
        SUM(op.reordered) AS reordered_count,
        ROUND(SUM(op.reordered) * 1.0 / COUNT(op.product_id), 4) AS reorder_ratio
    FROM orders o
    JOIN order_products__prior op ON o.order_id = op.order_id
    WHERE o.days_since_prior_order IS NOT NULL
    GROUP BY o.order_id, o.days_since_prior_order
)
SELECT 
    CASE 
        WHEN days_since_prior_order < 7 THEN 'Less than a week'
        WHEN days_since_prior_order < 14 THEN '1-2 weeks'
        WHEN days_since_prior_order < 21 THEN '2-3 weeks'
        WHEN days_since_prior_order < 28 THEN '3-4 weeks'
        ELSE 'More than 4 weeks'
    END AS order_interval,
    COUNT(*) AS num_orders,
    ROUND(AVG(basket_size), 2) AS avg_basket_size,
    ROUND(AVG(reordered_count), 2) AS avg_reordered_count,
    ROUND(AVG(reorder_ratio), 4) AS avg_reorder_ratio
FROM order_reorder_stats
GROUP BY order_interval
ORDER BY 
    CASE order_interval
        WHEN 'Less than a week' THEN 1
        WHEN '1-2 weeks' THEN 2
        WHEN '2-3 weeks' THEN 3
        WHEN '3-4 weeks' THEN 4
        ELSE 5
    END;

-- ********************************************************************************
-- TABLE: order_products__prior
-- Description: Contains products in prior orders
-- ********************************************************************************

-- Get basic information about the order_products__prior table
SELECT 
    'order_products__prior' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_order_ids,
    COUNT(DISTINCT product_id) AS unique_products,
    SUM(reordered) AS total_reordered,
    ROUND(SUM(reordered) * 1.0 / COUNT(*), 4) AS overall_reorder_rate,
    MIN(add_to_cart_order) AS min_cart_position,
    MAX(add_to_cart_order) AS max_cart_position,
    AVG(add_to_cart_order) AS avg_cart_position
FROM order_products__prior;

-- Distribution of basket sizes
SELECT 
    basket_size_bucket,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT order_id) FROM order_products__prior), 2) AS percentage_of_orders
FROM (
    SELECT 
        order_id,
        CASE 
            WHEN COUNT(*) = 1 THEN '1 item'
            WHEN COUNT(*) = 2 THEN '2 items'
            WHEN COUNT(*) = 3 THEN '3 items'
            WHEN COUNT(*) = 4 THEN '4 items'
            WHEN COUNT(*) = 5 THEN '5 items'
            WHEN COUNT(*) BETWEEN 6 AND 10 THEN '6-10 items'
            WHEN COUNT(*) BETWEEN 11 AND 20 THEN '11-20 items'
            ELSE 'More than 20 items'
        END AS basket_size_bucket
    FROM order_products__prior
    GROUP BY order_id
) basket_sizes
GROUP BY basket_size_bucket
ORDER BY 
    CASE basket_size_bucket
        WHEN '1 item' THEN 1
        WHEN '2 items' THEN 2
        WHEN '3 items' THEN 3
        WHEN '4 items' THEN 4
        WHEN '5 items' THEN 5
        WHEN '6-10 items' THEN 6
        WHEN '11-20 items' THEN 7
        ELSE 8
    END;

-- Analysis of add_to_cart_order (position in cart)
SELECT 
    add_to_cart_order AS cart_position,
    COUNT(*) AS item_count,
    SUM(reordered) AS reordered_count,
    ROUND(SUM(reordered) * 1.0 / COUNT(*), 4) AS reorder_rate
FROM order_products__prior
WHERE add_to_cart_order <= 20  -- Focus on first 20 positions only
GROUP BY add_to_cart_order
ORDER BY add_to_cart_order;

-- Reorder rates by add_to_cart_order buckets
SELECT 
    CASE 
        WHEN add_to_cart_order <= 5 THEN 'First 5 items'
        WHEN add_to_cart_order <= 10 THEN 'Items 6-10'
        WHEN add_to_cart_order <= 20 THEN 'Items 11-20'
        WHEN add_to_cart_order <= 50 THEN 'Items 21-50'
        ELSE 'Items 51+'
    END AS cart_position_bucket,
    COUNT(*) AS item_count,
    SUM(reordered) AS reordered_count,
    ROUND(SUM(reordered) * 1.0 / COUNT(*), 4) AS reorder_rate
FROM order_products__prior
GROUP BY cart_position_bucket
ORDER BY 
    CASE cart_position_bucket
        WHEN 'First 5 items' THEN 1
        WHEN 'Items 6-10' THEN 2
        WHEN 'Items 11-20' THEN 3
        WHEN 'Items 21-50' THEN 4
        ELSE 5
    END;

-- Relationship between reordering and day of week/hour of day
SELECT 
    o.order_dow AS day_of_week,
    o.order_hour_of_day AS hour_of_day,
    COUNT(op.product_id) AS product_count,
    SUM(op.reordered) AS reordered_count,
    ROUND(SUM(op.reordered) * 1.0 / COUNT(op.product_id), 4) AS reorder_rate
FROM order_products__prior op
JOIN orders o ON op.order_id = o.order_id
GROUP BY o.order_dow, o.order_hour_of_day
ORDER BY o.order_dow, o.order_hour_of_day;

-- Frequently co-purchased products (top 20 pairs)
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

-- ********************************************************************************
-- TABLE: order_products__train
-- Description: Contains products in training orders
-- ********************************************************************************

-- Get basic information about the order_products__train table
SELECT 
    'order_products__train' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_order_ids,
    COUNT(DISTINCT product_id) AS unique_products,
    SUM(reordered) AS total_reordered,
    ROUND(SUM(reordered) * 1.0 / COUNT(*), 4) AS overall_reorder_rate,
    MIN(add_to_cart_order) AS min_cart_position,
    MAX(add_to_cart_order) AS max_cart_position,
    AVG(add_to_cart_order) AS avg_cart_position
FROM order_products__train;

-- Distribution of basket sizes in training set
SELECT 
    basket_size_bucket,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT order_id) FROM order_products__train), 2) AS percentage_of_orders
FROM (
    SELECT 
        order_id,
        CASE 
            WHEN COUNT(*) = 1 THEN '1 item'
            WHEN COUNT(*) = 2 THEN '2 items'
            WHEN COUNT(*) = 3 THEN '3 items'
            WHEN COUNT(*) = 4 THEN '4 items'
            WHEN COUNT(*) = 5 THEN '5 items'
            WHEN COUNT(*) BETWEEN 6 AND 10 THEN '6-10 items'
            WHEN COUNT(*) BETWEEN 11 AND 20 THEN '11-20 items'
            ELSE 'More than 20 items'
        END AS basket_size_bucket
    FROM order_products__train
    GROUP BY order_id
) basket_sizes
GROUP BY basket_size_bucket
ORDER BY 
    CASE basket_size_bucket
        WHEN '1 item' THEN 1
        WHEN '2 items' THEN 2
        WHEN '3 items' THEN 3
        WHEN '4 items' THEN 4
        WHEN '5 items' THEN 5
        WHEN '6-10 items' THEN 6
        WHEN '11-20 items' THEN 7
        ELSE 8
    END;

-- Reorder rates by add_to_cart_order buckets in training set
SELECT 
    CASE 
        WHEN add_to_cart_order <= 5 THEN 'First 5 items'
        WHEN add_to_cart_order <= 10 THEN 'Items 6-10'
        WHEN add_to_cart_order <= 20 THEN 'Items 11-20'
        WHEN add_to_cart_order <= 50 THEN 'Items 21-50'
        ELSE 'Items 51+'
    END AS cart_position_bucket,
    COUNT(*) AS item_count,
    SUM(reordered) AS reordered_count,
    ROUND(SUM(reordered) * 1.0 / COUNT(*), 4) AS reorder_rate
FROM order_products__train
GROUP BY cart_position_bucket
ORDER BY 
    CASE cart_position_bucket
        WHEN 'First 5 items' THEN 1
        WHEN 'Items 6-10' THEN 2
        WHEN 'Items 11-20' THEN 3
        WHEN 'Items 21-50' THEN 4
        ELSE 5
    END;

-- Relationship between reordering and day of week/hour of day in training set
SELECT 
    o.order_dow AS day_of_week,
    o.order_hour_of_day AS hour_of_day,
    COUNT(op.product_id) AS product_count,
    SUM(op.reordered) AS reordered_count,
    ROUND(SUM(op.reordered) * 1.0 / COUNT(op.product_id), 4) AS reorder_rate
FROM order_products__train op
JOIN orders o ON op.order_id = o.order_id
GROUP BY o.order_dow, o.order_hour_of_day
ORDER BY o.order_dow, o.order_hour_of_day;

-- ********************************************************************************
-- CROSS-TABLE ANALYSIS: Customer Segments
-- Description: Advanced analysis joining multiple tables
-- ********************************************************************************

-- Customer segmentation by shopping behavior
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
    CASE 
        WHEN weekend_order_ratio >= 0.5 THEN 'Weekend Shopper'
        ELSE 'Weekday Shopper'
    END AS time_segment,
    COUNT(*) AS user_count,
    ROUND(AVG(total_orders), 1) AS avg_orders,
    ROUND(AVG(avg_basket_size), 1) AS avg_items_per_order,
    ROUND(AVG(avg_reorder_ratio), 3) AS avg_reorder_rate,
    ROUND(AVG(avg_days_between_orders), 1) AS avg_days_between_orders,
    ROUND(AVG(weekend_order_ratio), 3) AS weekend_order_rate
FROM user_metrics
GROUP BY basket_segment, frequency_segment, reorder_segment, time_segment
ORDER BY user_count DESC;

-- Department popularity by user segment
WITH user_segments AS (
    SELECT 
        o.user_id,
        CASE 
            WHEN COUNT(DISTINCT o.order_id) < 5 THEN 'New Customer'
            WHEN COUNT(DISTINCT o.order_id) < 10 THEN 'Regular Customer'
            ELSE 'Loyal Customer'
        END AS user_segment
    FROM orders o
    WHERE o.eval_set = 'prior'
    GROUP BY o.user_id
),
department_orders AS (
    SELECT 
        us.user_id,
        us.user_segment,
        d.department_id,
        d.department,
        COUNT(op.product_id) AS product_count
    FROM user_segments us
    JOIN orders o ON us.user_id = o.user_id
    JOIN order_products__prior op ON o.order_id = op.order_id
    JOIN products p ON op.product_id = p.product_id
    JOIN departments d ON p.department_id = d.department_id
    GROUP BY us.user_id, us.user_segment, d.department_id, d.department
)
SELECT 
    user_segment,
    department,
    COUNT(DISTINCT user_id) AS user_count,
    SUM(product_count) AS total_products_ordered,
    ROUND(AVG(product_count), 1) AS avg_products_per_user,
    ROUND(COUNT(DISTINCT user_id) * 100.0 / (
        SELECT COUNT(DISTINCT user_id) 
        FROM user_segments 
        WHERE user_segment = do.user_segment
    ), 2) AS pct_users_in_segment
FROM department_orders do
GROUP BY user_segment, department
ORDER BY user_segment, total_products_ordered DESC;

-- Analyzing product diversity preferences by user segment
WITH user_segments AS (
    SELECT 
        o.user_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        CASE 
            WHEN AVG(
                SELECT COUNT(DISTINCT p.aisle_id) 
                FROM order_products__prior op 
                JOIN products p ON op.product_id = p.product_id 
                WHERE op.order_id = o.order_id
            ) <= 2 THEN 'Low Diversity'
            WHEN AVG(
                SELECT COUNT(DISTINCT p.aisle_id) 
                FROM order_products__prior op 
                JOIN products p ON op.product_id = p.product_id 
                WHERE op.order_id = o.order_id
            ) <= 5 THEN 'Medium Diversity'
            ELSE 'High Diversity'
        END AS diversity_segment
    FROM orders o
    WHERE o.eval_set = 'prior'
    GROUP BY o.user_id
    HAVING COUNT(DISTINCT o.order_id) >= 5
)
SELECT
    diversity_segment,
    COUNT(DISTINCT user_id) AS user_count,
    ROUND(AVG(order_count), 1) AS avg_orders_per_user
FROM user_segments
GROUP BY diversity_segment
ORDER BY user_count DESC;

-- Temporal patterns: Analyzing ordering habits by day and hour segments
WITH user_time_segments AS (
    SELECT 
        o.user_id,
        CASE 
            WHEN AVG(CASE WHEN o.order_hour_of_day < 12 THEN 1 ELSE 0 END) > 0.5 THEN 'Morning Shopper'
            WHEN AVG(CASE WHEN o.order_hour_of_day BETWEEN 12 AND 17 THEN 1 ELSE 0 END) > 0.5 THEN 'Afternoon Shopper'
            ELSE 'Evening Shopper'
        END AS time_of_day_segment,
        CASE 
            WHEN AVG(CASE WHEN o.order_dow IN (0, 6) THEN 1 ELSE 0 END) > 0.5 THEN 'Weekend Shopper'
            ELSE 'Weekday Shopper'
        END AS day_segment
    FROM orders o
    WHERE o.eval_set = 'prior'
    GROUP BY o.user_id
    HAVING COUNT(DISTINCT o.order_id) >= 5
)
SELECT
    time_of_day_segment,
    day_segment,
    COUNT(DISTINCT user_id) AS user_count,
    ROUND(COUNT(DISTINCT user_id) * 100.0 / (SELECT COUNT(*) FROM user_time_segments), 2) AS percentage
FROM user_time_segments
GROUP BY time_of_day_segment, day_segment
ORDER BY user_count DESC;

-- Product affinity analysis: Which products are frequently bought together?
WITH product_pairs AS (
    SELECT 
        a.product_id AS product_1,
        b.product_id AS product_2,
        COUNT(DISTINCT a.order_id) AS order_count,
        COUNT(DISTINCT a.order_id) * 100.0 / (
            SELECT COUNT(DISTINCT order_id) 
            FROM order_products__prior 
            WHERE product_id = a.product_id
        ) AS pct_of_product1_orders,
        COUNT(DISTINCT a.order_id) * 100.0 / (
            SELECT COUNT(DISTINCT order_id) 
            FROM order_products__prior 
            WHERE product_id = b.product_id
        ) AS pct_of_product2_orders
    FROM order_products__prior a
    JOIN order_products__prior b ON a.order_id = b.order_id AND a.product_id < b.product_id
    GROUP BY a.product_id, b.product_id
    HAVING COUNT(DISTINCT a.order_id) >= 100
)
SELECT 
    p1.product_name AS product_1_name,
    p2.product_name AS product_2_name,
    pp.order_count AS times_bought_together,
    ROUND(pp.pct_of_product1_orders, 2) AS pct_of_product1_orders,
    ROUND(pp.pct_of_product2_orders, 2) AS pct_of_product2_orders
FROM product_pairs pp
JOIN products p1 ON pp.product_1 = p1.product_id
JOIN products p2 ON pp.product_2 = p2.product_id
ORDER BY pp.order_count DESC
LIMIT 20;

-- User behavior analysis: First time purchase vs. reordering preferences
WITH user_first_purchases AS (
    SELECT 
        o.user_id,
        MIN(o.order_number) AS first_order,
        op.product_id,
        p.product_name,
        d.department
    FROM orders o
    JOIN order_products__prior op ON o.order_id = op.order_id
    JOIN products p ON op.product_id = p.product_id
    JOIN departments d ON p.department_id = d.department_id
    GROUP BY o.user_id, op.product_id, p.product_name, d.department
),
user_repeat_purchases AS (
    SELECT 
        o.user_id,
        op.product_id,
        COUNT(*) AS purchase_count
    FROM orders o
    JOIN order_products__prior op ON o.order_id = op.order_id
    WHERE o.order_number > (SELECT MIN(order_number) FROM orders WHERE user_id = o.user_id)
    GROUP BY o.user_id, op.product_id
)
SELECT 
    ufp.department,
    COUNT(DISTINCT ufp.user_id) AS users_with_first_purchase,
    COUNT(DISTINCT urp.user_id) AS users_with_repeat_purchase,
    ROUND(COUNT(DISTINCT urp.user_id) * 100.0 / COUNT(DISTINCT ufp.user_id), 2) AS repeat_purchase_pct
FROM user_first_purchases ufp
LEFT JOIN user_repeat_purchases urp ON ufp.user_id = urp.user_id AND ufp.product_id = urp.product_id
GROUP BY ufp.department
ORDER BY repeat_purchase_pct DESC;
