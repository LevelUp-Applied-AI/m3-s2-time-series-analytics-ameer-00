-- ==========================================================================
-- Cohort Analysis: Customer Retention by First-Purchase Month
--
-- Uses ROW_NUMBER() to identify each customer's first purchase,
-- then tracks how many return in subsequent months.
-- ==========================================================================


-- Step 1: Identify each customer's first completed purchase month (their cohort)
WITH first_purchase AS (
    SELECT
        o.customer_id,
        MIN(o.order_date)                              AS first_order_date,
        DATE_TRUNC('month', MIN(o.order_date))::DATE   AS cohort_month
    FROM orders o
    WHERE o.status = 'completed'
    GROUP BY o.customer_id
),

-- Step 2: Rank every completed order per customer (ROW_NUMBER marks first purchase)
customer_orders_ranked AS (
    SELECT
        o.customer_id,
        o.order_date,
        DATE_TRUNC('month', o.order_date)::DATE AS order_month,
        fp.cohort_month,
        ROW_NUMBER() OVER (
            PARTITION BY o.customer_id
            ORDER BY o.order_date
        ) AS purchase_rank
    FROM orders o
    JOIN first_purchase fp ON fp.customer_id = o.customer_id
    WHERE o.status = 'completed'
),

-- Step 3: Compute how many months after the cohort each order happened (period index)
cohort_activity AS (
    SELECT
        cohort_month,
        customer_id,
        -- Period 0 = month of first purchase, Period 1 = one month later, etc.
        (DATE_PART('year',  order_month) - DATE_PART('year',  cohort_month)) * 12 +
        (DATE_PART('month', order_month) - DATE_PART('month', cohort_month))
            AS period_number
    FROM customer_orders_ranked
),

-- Step 4: Count distinct active customers per cohort per period
cohort_retention AS (
    SELECT
        cohort_month,
        period_number,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM cohort_activity
    GROUP BY cohort_month, period_number
),

-- Step 5: Pull cohort sizes (Period 0 = total cohort size)
cohort_sizes AS (
    SELECT
        cohort_month,
        active_customers AS cohort_size
    FROM cohort_retention
    WHERE period_number = 0
)

-- Final output: retention rate per cohort per period
SELECT
    cr.cohort_month,
    cs.cohort_size,
    cr.period_number,
    cr.active_customers,
    ROUND(
        100.0 * cr.active_customers / cs.cohort_size, 1
    ) AS retention_pct
FROM cohort_retention cr
JOIN cohort_sizes cs ON cs.cohort_month = cr.cohort_month
ORDER BY cr.cohort_month, cr.period_number;
