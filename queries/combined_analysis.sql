-- ==========================================================================
-- Combined Analysis: Multiple Window Functions in Single Queries
--
-- Query 1: Category revenue share with moving average and period-over-period growth
-- Query 2: Cohort retention rates with month-over-month change
-- ==========================================================================


-- ============================================================
-- Query 1: Category Performance — Revenue Share + 3-Month
--           Moving Average + Month-over-Month Growth
-- ============================================================

WITH monthly_category_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_date)::DATE   AS order_month,
        p.category,
        SUM(oi.quantity * oi.unit_price)           AS category_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p     ON p.product_id = oi.product_id
    WHERE o.status = 'completed'
    GROUP BY DATE_TRUNC('month', o.order_date), p.category
),

category_with_windows AS (
    SELECT
        order_month,
        category,
        category_revenue,

        -- Revenue share within each month (across all categories)
        ROUND(
            100.0 * category_revenue
                  / SUM(category_revenue) OVER (PARTITION BY order_month),
            1
        ) AS monthly_share_pct,

        -- 3-month moving average per category
        ROUND(AVG(category_revenue) OVER (
            PARTITION BY category
            ORDER BY order_month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2) AS revenue_3mo_avg,

        -- Month-over-month growth per category using LAG
        ROUND(
            100.0 * (category_revenue
                     - LAG(category_revenue) OVER (
                         PARTITION BY category ORDER BY order_month))
                  / NULLIF(
                        LAG(category_revenue) OVER (
                            PARTITION BY category ORDER BY order_month),
                        0),
            1
        ) AS mom_growth_pct,

        -- Rank categories by revenue within each month
        RANK() OVER (
            PARTITION BY order_month
            ORDER BY category_revenue DESC
        ) AS monthly_rank

    FROM monthly_category_revenue
)

SELECT
    order_month,
    category,
    ROUND(category_revenue, 2) AS category_revenue,
    monthly_share_pct,
    revenue_3mo_avg,
    mom_growth_pct,
    monthly_rank
FROM category_with_windows
ORDER BY order_month, monthly_rank;


-- ============================================================
-- Query 2: Cohort Retention with Period-over-Period Change
--           Combines ROW_NUMBER (cohort labeling) + LAG
--           (retention change) + window aggregation
-- ============================================================

WITH first_purchase AS (
    -- Identify each customer's cohort using their earliest completed order
    SELECT
        customer_id,
        MIN(order_date)                              AS first_order_date,
        DATE_TRUNC('month', MIN(order_date))::DATE   AS cohort_month
    FROM orders
    WHERE status = 'completed'
    GROUP BY customer_id
),

customer_numbered AS (
    -- ROW_NUMBER: rank customers within each cohort by their first purchase date
    SELECT
        customer_id,
        cohort_month,
        first_order_date,
        ROW_NUMBER() OVER (
            PARTITION BY cohort_month
            ORDER BY first_order_date
        ) AS customer_rank_in_cohort
    FROM first_purchase
),

cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_size
    FROM first_purchase
    GROUP BY cohort_month
),

subsequent_orders AS (
    SELECT
        o.customer_id,
        fp.cohort_month,
        DATE_TRUNC('month', o.order_date)::DATE AS order_month,
        (DATE_PART('year',  DATE_TRUNC('month', o.order_date)) -
         DATE_PART('year',  fp.cohort_month)) * 12 +
        (DATE_PART('month', DATE_TRUNC('month', o.order_date)) -
         DATE_PART('month', fp.cohort_month))   AS period_number
    FROM orders o
    JOIN first_purchase fp ON fp.customer_id = o.customer_id
    WHERE o.status = 'completed'
),

retention_counts AS (
    SELECT
        cohort_month,
        period_number,
        COUNT(DISTINCT customer_id) AS retained_customers
    FROM subsequent_orders
    GROUP BY cohort_month, period_number
),

retention_with_rate AS (
    SELECT
        rc.cohort_month,
        cs.cohort_size,
        rc.period_number,
        rc.retained_customers,
        ROUND(100.0 * rc.retained_customers / cs.cohort_size, 1) AS retention_pct,

        -- How did retention rate change compared to the previous period?
        ROUND(
            (100.0 * rc.retained_customers / cs.cohort_size)
            - LAG(100.0 * rc.retained_customers / cs.cohort_size) OVER (
                PARTITION BY rc.cohort_month
                ORDER BY rc.period_number
            ),
            1
        ) AS retention_pct_change,

        -- Running average retention across all periods for this cohort
        ROUND(AVG(100.0 * rc.retained_customers / cs.cohort_size) OVER (
            PARTITION BY rc.cohort_month
            ORDER BY rc.period_number
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ), 1) AS avg_retention_to_date

    FROM retention_counts rc
    JOIN cohort_sizes cs ON cs.cohort_month = rc.cohort_month
)

SELECT
    cohort_month,
    cohort_size,
    period_number,
    retained_customers,
    retention_pct,
    retention_pct_change,
    avg_retention_to_date
FROM retention_with_rate
ORDER BY cohort_month, period_number;
