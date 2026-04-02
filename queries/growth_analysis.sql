-- ==========================================================================
-- Growth Analysis: Month-over-Month and Quarter-over-Quarter Revenue & Orders
--
-- Uses LAG() to compare each period to the previous one and compute
-- growth rates for both revenue and order volume.
-- ==========================================================================


-- Step 1: Aggregate completed revenue and order count by month
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_date)::DATE   AS order_month,
        COUNT(DISTINCT o.order_id)                 AS total_orders,
        SUM(oi.quantity * oi.unit_price)           AS total_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'completed'
    GROUP BY DATE_TRUNC('month', o.order_date)
),

-- Step 2: Add LAG values for month-over-month comparison
mom_growth AS (
    SELECT
        order_month,
        total_orders,
        total_revenue,
        LAG(total_revenue) OVER (ORDER BY order_month) AS prev_month_revenue,
        LAG(total_orders)  OVER (ORDER BY order_month) AS prev_month_orders,
        ROUND(
            100.0 * (total_revenue - LAG(total_revenue) OVER (ORDER BY order_month))
                  / NULLIF(LAG(total_revenue) OVER (ORDER BY order_month), 0),
            1
        ) AS mom_revenue_growth_pct,
        ROUND(
            100.0 * (total_orders - LAG(total_orders) OVER (ORDER BY order_month))
                  / NULLIF(LAG(total_orders) OVER (ORDER BY order_month), 0),
            1
        ) AS mom_order_growth_pct
    FROM monthly_revenue
),

-- Step 3: Map each month to its fiscal quarter
quarterly_revenue AS (
    SELECT
        DATE_TRUNC('quarter', order_month)::DATE AS quarter_start,
        SUM(total_revenue)                        AS quarterly_revenue,
        SUM(total_orders)                         AS quarterly_orders
    FROM monthly_revenue
    GROUP BY DATE_TRUNC('quarter', order_month)
),

-- Step 4: Quarter-over-quarter growth using LAG
qoq_growth AS (
    SELECT
        quarter_start,
        quarterly_revenue,
        quarterly_orders,
        LAG(quarterly_revenue) OVER (ORDER BY quarter_start) AS prev_quarter_revenue,
        ROUND(
            100.0 * (quarterly_revenue - LAG(quarterly_revenue) OVER (ORDER BY quarter_start))
                  / NULLIF(LAG(quarterly_revenue) OVER (ORDER BY quarter_start), 0),
            1
        ) AS qoq_revenue_growth_pct,
        ROUND(
            100.0 * (quarterly_orders - LAG(quarterly_orders) OVER (ORDER BY quarter_start))
                  / NULLIF(LAG(quarterly_orders) OVER (ORDER BY quarter_start), 0),
            1
        ) AS qoq_order_growth_pct
    FROM quarterly_revenue
)

-- Output 1: Month-over-Month Growth
SELECT
    'MoM' AS period_type,
    order_month::TEXT AS period,
    total_revenue,
    total_orders,
    mom_revenue_growth_pct AS revenue_growth_pct,
    mom_order_growth_pct   AS order_growth_pct
FROM mom_growth

UNION ALL

-- Output 2: Quarter-over-Quarter Growth
SELECT
    'QoQ'                    AS period_type,
    quarter_start::TEXT      AS period,
    quarterly_revenue        AS total_revenue,
    quarterly_orders         AS total_orders,
    qoq_revenue_growth_pct   AS revenue_growth_pct,
    qoq_order_growth_pct     AS order_growth_pct
FROM qoq_growth

ORDER BY period_type DESC, period;

