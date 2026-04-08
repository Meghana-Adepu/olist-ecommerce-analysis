-- =====================================================
-- OLIST ECOMMERCE DATASET
-- Data Cleaning & Validation
--
-- Author: Meghana Adepu
-- Dataset: Brazilian E-commerce Public Dataset (Olist)
--
-- Purpose:
-- Perform data quality checks before conducting
-- sales, customer, and delivery analytics.

-- Checks Included:
-- • Row count validation
-- • Duplicate detection
-- • NULL value analysis
-- • Order status validation
-- • Delivery date validation
-- • Price validation
-- • Payment consistency checks
-- • Referential integrity checks
-- =====================================================



-- =====================================================
-- 1. ROW COUNT VALIDATION
-- Ensure all datasets were imported correctly
-- =====================================================

SELECT COUNT(*) AS customer_count FROM customers;
SELECT COUNT(*) AS order_count FROM orders;
SELECT COUNT(*) AS order_items_count FROM order_items;
SELECT COUNT(*) AS payment_count FROM order_payments;
SELECT COUNT(*) AS review_count FROM order_reviews;
SELECT COUNT(*) AS product_count FROM products;
SELECT COUNT(*) AS seller_count FROM sellers;
SELECT COUNT(*) AS geolocation_count FROM geolocation;



-- =====================================================
-- 2. DUPLICATE PRIMARY KEY CHECKS
-- Primary keys should contain unique values
-- =====================================================

-- Customers
SELECT COUNT(customer_id) - COUNT(DISTINCT customer_id) AS duplicate_customers
FROM customers;

-- Orders
SELECT COUNT(order_id) - COUNT(DISTINCT order_id) AS duplicate_orders
FROM orders;

-- Products
SELECT COUNT(product_id) - COUNT(DISTINCT product_id) AS duplicate_products
FROM products;



-- =====================================================
-- 3. NULL VALUE ANALYSIS
-- Identify missing values in important columns
-- =====================================================

-- Check NULL timestamps in orders
SELECT
COUNT(*) FILTER (WHERE order_approved_at IS NULL) AS approved_null,
COUNT(*) FILTER (WHERE order_delivered_customer_date IS NULL) AS delivered_null
FROM orders;

-- Identify products missing category information
SELECT *
FROM products
WHERE product_category_name IS NULL;



-- =====================================================
-- 4. DATA CLEANING
-- Handle missing or inconsistent values
-- =====================================================

-- Replace missing product categories with 'unknown'
UPDATE products
SET product_category_name = 'unknown'
WHERE product_category_name IS NULL;



-- =====================================================
-- 5. ORDER STATUS VALIDATION
-- Verify allowed order status values
-- =====================================================

SELECT DISTINCT order_status
FROM orders;



-- =====================================================
-- 6. DELIVERY DATA VALIDATION
-- Delivered orders must have delivery timestamp
-- =====================================================

SELECT *
FROM orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NULL;



-- =====================================================
-- 7. DELIVERY LOGIC VALIDATION
-- Delivery date must be after purchase date
-- =====================================================

SELECT *
FROM orders
WHERE order_delivered_customer_date < order_purchase_timestamp;



-- =====================================================
-- 8. PRICE VALIDATION
-- Ensure product prices and freight costs are non-negative
-- =====================================================

SELECT *
FROM order_items
WHERE price < 0
OR freight_value < 0;



-- =====================================================
-- 9. PAYMENT CONSISTENCY CHECK
-- Compare total payments with order item values
-- =====================================================

-- Total payments collected
SELECT
SUM(payment_value) AS total_payment
FROM order_payments;

-- Total order value (product price + freight)
SELECT
SUM(price + freight_value) AS total_order_value
FROM order_items;

-- NOTE:
-- Some discrepancies may occur because customers may use
-- multiple payment methods (e.g., credit card + voucher).



-- =====================================================
-- 10. ORDER ITEM DUPLICATE CHECK
-- Ensure order items are unique per order
-- =====================================================

SELECT order_id, order_item_id, COUNT(*)
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;



-- =====================================================
-- 11. REFERENTIAL INTEGRITY CHECK
-- Ensure orders reference valid customers
-- =====================================================

SELECT *
FROM orders o
LEFT JOIN customers c
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;



-- =====================================================
-- 12. REVIEW SCORE VALIDATION
-- Review scores should range between 1 and 5
-- =====================================================

SELECT DISTINCT review_score
FROM order_reviews
ORDER BY review_score;