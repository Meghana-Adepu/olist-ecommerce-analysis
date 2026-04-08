-- =====================================================
-- OLIST ECOMMERCE DATASET
-- Advanced Business Analysis
--
-- Author: Meghana Adepu
--
-- Purpose:
-- Perform deeper analysis on customer behavior,
-- seller performance, revenue contribution,
-- and logistics efficiency.
-- =====================================================



-- =====================================================
-- SECTION 1: CUSTOMER ANALYSIS
-- =====================================================

-- -----------------------------------------------------
-- 1. CUSTOMER PURCHASE FREQUENCY
-- Identify repeat vs one-time customers
-- -----------------------------------------------------

WITH customer_orders AS
(
SELECT
c.customer_unique_id,
COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
)

SELECT
CASE
WHEN total_orders = 1 THEN 'One-time Customer'
ELSE 'Repeat Customer'
END AS customer_type,
COUNT(*) AS customer_count
FROM customer_orders
GROUP BY customer_type;



-- -----------------------------------------------------
-- 2. CUSTOMER LIFETIME VALUE
-- Total revenue generated per customer
-- -----------------------------------------------------

SELECT
c.customer_unique_id,
ROUND(SUM(oi.price + oi.freight_value),2) AS customer_lifetime_value
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY customer_lifetime_value DESC
LIMIT 10;



-- =====================================================
-- SECTION 2: SELLER & MARKETPLACE ANALYSIS
-- =====================================================

-- -----------------------------------------------------
-- 3. TOP SELLERS BY REVENUE
-- Rank sellers based on total sales
-- -----------------------------------------------------

SELECT *
FROM
(
SELECT
seller_id,
SUM(price + freight_value) AS revenue,
RANK() OVER (ORDER BY SUM(price + freight_value) DESC) AS seller_rank
FROM order_items
GROUP BY seller_id
) ranked_sellers
WHERE seller_rank <= 10;



-- -----------------------------------------------------
-- 4. REVENUE SHARE OF TOP SELLERS
-- Identify revenue concentration across sellers
-- -----------------------------------------------------

WITH seller_revenue AS
(
SELECT
seller_id,
SUM(price + freight_value) AS revenue
FROM order_items
GROUP BY seller_id
)

SELECT
seller_id,
revenue,
ROUND(100.0 * revenue / SUM(revenue) OVER(),2) AS revenue_percentage
FROM seller_revenue
ORDER BY revenue DESC
LIMIT 10;



-- -----------------------------------------------------
-- 5. TOP 10% SELLERS REVENUE CONTRIBUTION
-- Analyze revenue concentration using deciles
-- -----------------------------------------------------

WITH seller_revenue AS
(
SELECT
seller_id,
SUM(price + freight_value) AS revenue
FROM order_items
GROUP BY seller_id
),

ranked_sellers AS
(
SELECT
seller_id,
revenue,
NTILE(10) OVER (ORDER BY revenue DESC) AS revenue_decile
FROM seller_revenue
)

SELECT
revenue_decile,
ROUND(SUM(revenue),2) AS total_revenue
FROM ranked_sellers
GROUP BY revenue_decile
ORDER BY revenue_decile;



-- =====================================================
-- SECTION 3: REVENUE & SALES TRENDS
-- =====================================================

-- -----------------------------------------------------
-- 6. MONTHLY REVENUE TREND
-- Track revenue growth over time
-- -----------------------------------------------------

SELECT
DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
ROUND(SUM(oi.price + oi.freight_value),2) AS revenue
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY month
ORDER BY month;



-- =====================================================
-- SECTION 4: LOGISTICS & DELIVERY PERFORMANCE
-- =====================================================

-- -----------------------------------------------------
-- 7. DELIVERY DELAY ANALYSIS
-- Compare actual vs estimated delivery dates
-- -----------------------------------------------------

SELECT
ROUND(
AVG(order_delivered_customer_date::date
- order_estimated_delivery_date::date),2
) AS avg_delay_days
FROM orders
WHERE order_status = 'delivered';



-- -----------------------------------------------------
-- 8. DELIVERY PERFORMANCE VS CUSTOMER REVIEWS
-- Check if delivery delays affect customer ratings
-- -----------------------------------------------------

SELECT
CASE
WHEN order_delivered_customer_date::date
<= order_estimated_delivery_date::date
THEN 'On Time'
ELSE 'Delayed'
END AS delivery_status,
ROUND(AVG(r.review_score),2) AS avg_review_score
FROM orders o
JOIN order_reviews r
ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY delivery_status;