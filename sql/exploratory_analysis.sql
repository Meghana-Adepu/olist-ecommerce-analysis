-- =====================================================
-- OLIST ECOMMERCE DATASET
-- Exploratory Data Analysis (EDA)
--
-- Author: Meghana Adepu
-- Dataset: Brazilian E-commerce Public Dataset (Olist)
--
-- Purpose:
-- Perform initial analysis to understand sales,
-- customer behavior, payment patterns, and logistics
-- performance before deeper business analysis.
-- =====================================================



-- =====================================================
-- 1. TOTAL ORDERS
-- Understand overall order volume
-- =====================================================

SELECT COUNT(*) AS total_orders
FROM orders;



-- =====================================================
-- 2. TOTAL REVENUE
-- Revenue = product price + freight value
-- =====================================================

SELECT
ROUND(SUM(oi.price + oi.freight_value),2) AS total_revenue
FROM order_items oi
JOIN orders o
ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered';


-- =====================================================
-- 3. TOTAL UNIQUE CUSTOMERS
-- Count unique customers who placed orders
-- =====================================================

SELECT COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers;



-- =====================================================
-- 4. AVERAGE ORDER VALUE
-- Indicates customer spending behavior
-- =====================================================

SELECT
ROUND(SUM(price + freight_value) / COUNT(DISTINCT order_id),2)
AS avg_order_value
FROM order_items;



-- =====================================================
-- 5. MONTHLY ORDER TREND
-- Helps understand seasonality in sales
-- =====================================================

SELECT
DATE_TRUNC('month', order_purchase_timestamp) AS month,
COUNT(order_id) AS total_orders
FROM orders
WHERE order_status = 'delivered'
GROUP BY month
ORDER BY month;



-- =====================================================
-- 6. TOP 10 PRODUCT CATEGORIES BY SALES
-- Identify most popular product categories
-- =====================================================

SELECT
pct.product_category_name_english AS category,
ROUND(SUM(oi.price),2) AS total_sales
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
JOIN product_category_translation pct
ON p.product_category_name = pct.product_category_name
GROUP BY category
ORDER BY total_sales DESC
LIMIT 10;



-- =====================================================
-- 7. PAYMENT METHOD DISTRIBUTION
-- Understand how customers prefer to pay
-- =====================================================

SELECT
payment_type,
COUNT(*) AS payment_count
FROM order_payments
GROUP BY payment_type
ORDER BY payment_count DESC;



-- =====================================================
-- 8. AVERAGE DELIVERY TIME
-- Measure logistics efficiency
-- =====================================================

SELECT
ROUND(
AVG(order_delivered_customer_date::date - order_purchase_timestamp::date),2
) AS avg_delivery_time_days
FROM orders
WHERE order_status = 'delivered';



-- =====================================================
-- 9. TOP SELLERS BY REVENUE
-- Identify best performing sellers
-- =====================================================

SELECT
seller_id,
ROUND(SUM(price + freight_value),2) AS revenue
FROM order_items
GROUP BY seller_id
ORDER BY revenue DESC
LIMIT 10;



-- =====================================================
-- 10. REVIEW SCORE DISTRIBUTION
-- Understand customer satisfaction
-- =====================================================

SELECT
review_score,
COUNT(*) AS review_count
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;


-- =====================================================
-- 11. ORDER STATUS DISTRIBUTION
-- Understand how many orders were delivered, canceled etc.
-- =====================================================

SELECT
order_status,
COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- =====================================================
-- 12. TOP 10 CITIES BY NUMBER OF ORDERS
-- Identify geographic demand for products
-- =====================================================

SELECT
LOWER(customer_city) AS city,
COUNT(o.order_id) AS total_orders
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY city
ORDER BY total_orders DESC
LIMIT 10;


-- =====================================================
-- 13. AVERAGE CUSTOMER REVIEW SCORE
-- Evaluate customer satisfaction levels
-- =====================================================

SELECT
ROUND(AVG(review_score),2) AS avg_review_score
FROM order_reviews;