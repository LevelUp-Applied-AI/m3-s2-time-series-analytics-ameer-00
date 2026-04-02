-- ==========================================================================
-- Trend Analysis: 7-Day and 30-Day Moving Averages
--
-- Uses ROWS BETWEEN window frame specifications to compute rolling averages
-- on daily revenue, revealing short-term noise vs. long-term momentum.
-- ==========================================================================


-- Step 1: Daily revenue from completed orders only
WITH daily_revenue AS (
    SELECT
        o.order_date,
        COUNT(DISTINCT o.order_id)       AS daily_orders,
        SUM(oi.quantity * oi.unit_price) AS daily_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'completed'
    GROUP BY o.order_date
),

-- Step 2: Fill in missing days with zero (ensures the window isn't skewed by gaps)
date_spine AS (
    SELECT generate_series(
        (SELECT MIN(order_date) FROM daily_revenue),
        (SELECT MAX(order_date) FROM daily_revenue),
        INTERVAL '1 day'
    )::DATE AS order_date
),

daily_filled AS (
    SELECT
        ds.order_date,
        COALESCE(dr.daily_orders,  0) AS daily_orders,
        COALESCE(dr.daily_revenue, 0) AS daily_revenue
    FROM date_spine ds
    LEFT JOIN daily_revenue dr ON dr.order_date = ds.order_date
),

-- Step 3: Apply 7-day and 30-day rolling averages using ROWS BETWEEN
moving_averages AS (
    SELECT
        order_date,
        daily_orders,
        ROUND(daily_revenue, 2) AS daily_revenue,

        -- 7-day moving average: current day + 6 preceding days
        ROUND(AVG(daily_revenue) OVER (
            ORDER BY order_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 2) AS revenue_7d_avg,

        -- 30-day moving average: current day + 29 preceding days
        ROUND(AVG(daily_revenue) OVER (
            ORDER BY order_date
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ), 2) AS revenue_30d_avg,

        -- 7-day moving sum for orders
        SUM(daily_orders) OVER (
            ORDER BY order_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS orders_7d_rolling,

        -- Cumulative revenue (running total for the full period)
        ROUND(SUM(daily_revenue) OVER (
            ORDER BY order_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ), 2) AS cumulative_revenue

    FROM daily_filled
)

SELECT
    order_date,
    daily_orders,
    daily_revenue,
    revenue_7d_avg,
    revenue_30d_avg,
    orders_7d_rolling,
    cumulative_revenue,
    -- Flag days where 7-day avg crosses above 30-day avg (upward momentum signal)
    CASE
        WHEN revenue_7d_avg > revenue_30d_avg THEN 'Above Trend'
        WHEN revenue_7d_avg < revenue_30d_avg THEN 'Below Trend'
        ELSE 'At Trend'
    END AS trend_signal
FROM moving_averages
ORDER BY order_date;
