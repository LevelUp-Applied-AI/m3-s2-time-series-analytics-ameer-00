# Executive Report: E-Commerce Performance Analysis
**Period:** April 2025 – March 2026  
**Prepared by:** Business Intelligence Team  
**Date:** April 2026

---

## Executive Summary

The business delivered strong revenue growth across the 12-month period, with total completed revenue reaching **$9,302,847** from **27,711 completed orders**. Growth was not linear — the business experienced a pronounced Q4 2025 holiday surge, a post-holiday dip in January 2026, and a strong recovery through Q1 2026. Electronics dominates category mix, while customer retention sits near **50%** across most cohorts, indicating a healthy repeat-purchase base with room to improve.

---

## Revenue Trends

### Overall Growth

Monthly revenue grew from **$217,845 in April 2025** to **$1,530,932 in March 2026** — a **7x increase** over the 12-month period. Growth was consistent and accelerating through Q2 and Q3 2025, then spiked dramatically in Q4.

| Month | Revenue | Notes |
|---|---|---|
| Apr 2025 | $217,845 | Baseline |
| Jul 2025 | $434,376 | 2× baseline in 3 months |
| Oct 2025 | $791,472 | Pre-holiday ramp |
| Nov 2025 | $1,194,372 | Holiday surge begins |
| Dec 2025 | $1,708,515 | Peak month — 7.8× April |
| Jan 2026 | $729,311 | Post-holiday normalization (−57%) |
| Mar 2026 | $1,530,932 | Strong Q1 recovery |

### Quarter-over-Quarter Growth

| Quarter | Revenue | QoQ Growth |
|---|---|---|
| Q2 2025 (Apr–Jun) | $872,009 | — |
| Q3 2025 (Jul–Sep) | $1,530,860 | +75.6% |
| Q4 2025 (Oct–Dec) | $3,694,359 | +141.3% |
| Q1 2026 (Jan–Mar) | $3,204,619 | −13.3% |

Q4 2025 was the growth engine of the year, contributing **39.7% of annual revenue** in just three months. Q1 2026, despite the January dip, still tracked above Q3 2025 levels — indicating that the business has structurally grown, not just seasonally spiked.

### Order Health

Of **30,200 total orders**, 91.8% were completed, with only 4.2% returned and 4.0% cancelled. These are healthy ratios for an e-commerce operation.

---

## Customer Retention

### Cohort Overview

Customers were grouped into cohorts by their first completed purchase month. The April 2025 cohort — the earliest and largest — had **499 customers** and serves as the clearest long-term retention signal.

| Cohort | Size | Period 1 Retention | Period 2 Retention | Period 3 Retention |
|---|---|---|---|---|
| Apr 2025 | 499 | 50.3% | 51.1% | 47.5% |
| May 2025 | 342 | 43.0% | 43.3% | 44.4% |
| Jun 2025 | 373 | 44.8% | 39.7% | 41.6% |
| Jul 2025 | 380 | 38.2% | 40.5% | 55.3% |
| Aug 2025 | 374 | 38.0% | 51.6% | 51.1% |
| Sep 2025 | 406 | 48.5% | 48.3% | 58.6% |

### Key Retention Findings

**Retention is stable around 40–55%.** The April 2025 cohort (the longest-observed) shows no meaningful drop-off from Period 1 to Period 3, suggesting that customers who return once tend to remain active.

**Later cohorts show improving retention.** September 2025 reached **58.6% retention by Period 3** — the highest observed — likely reflecting better product mix and marketing maturity by that point in the year.

**The December 2025 cohort (618 customers)** is the largest single cohort, acquired during peak season. Its long-term retention rate will be the key metric to watch in the coming quarters, as holiday-acquired customers often churn faster than organic ones.

### Implications for Acquisition Strategy

Given roughly 50% second-month retention, each acquired customer is worth approximately **2× their first-order value** in expected lifetime value over 3 months. Acquisition investment should prioritize channels that deliver customers similar in profile to the September–October 2025 cohorts, which showed the strongest multi-period retention.

---

## Category Performance

### Revenue by Category (Full Period)

| Category | Revenue | Share |
|---|---|---|
| Electronics | $5,192,775 | 55.8% |
| Sports | $1,338,680 | 14.4% |
| Home & Kitchen | $1,284,412 | 13.8% |
| Clothing | $988,059 | 10.6% |
| Health & Beauty | $381,209 | 4.1% |
| Books | $116,712 | 1.3% |

### Category Insights

**Electronics is the clear revenue anchor**, accounting for over half of all revenue. Its dominance means overall business performance is tightly correlated with Electronics demand — a risk factor worth monitoring.

**Sports and Home & Kitchen are the next-tier growth categories**, together contributing 28.2% of revenue. Both categories have high average order values relative to Clothing and Books, and benefit from gift-season demand.

**Books is significantly underperforming** at 1.3% revenue share despite being one of the five listed categories. With 300 products in the catalog, this suggests either low price points, low traffic, or poor product-market fit. The category likely requires a strategic decision: invest in growth or rationalize the catalog.

**Health & Beauty at 4.1%** has room to grow as a complementary category — it benefits from repeat-purchase behavior (consumables) more than Electronics, which is a one-time purchase category.

---

## Recommendations

**1. Protect and grow the Electronics category, but diversify revenue mix.**  
Electronics at 55.8% of revenue creates concentration risk. Invest in growing Sports and Home & Kitchen — both already have meaningful revenue bases — to reduce dependence on a single category.

**2. Build a retention program for the December 2025 cohort.**  
At 618 customers, this is the largest cohort acquired. Holiday-acquired customers have lower brand loyalty on average. A targeted email or loyalty program in Q2 2026 could significantly improve their Period 2–3 retention.

**3. Evaluate the Books category.**  
At $116,712 annual revenue across what is presumably a broad catalog, Books is unlikely to be margin-positive after operational costs. The business should either consolidate the SKU count to bestsellers only or redirect that shelf space to higher-performing categories.

**4. Plan Q1 2026 inventory and marketing around the January dip.**  
January revenue dropped 57% from December — a predictable post-holiday pattern. Q1 2026 already showed recovery ($1.53M in March), but earlier intervention in January through promotions or bundled offers could soften the dip.

**5. Use September–October cohort profiles to guide acquisition targeting.**  
These cohorts showed 55–58% Period 3 retention — the best observed. Analyzing what channels, geographies, or product entry points these customers used will inform higher-ROI acquisition spending.

---

## Methodology Notes

- Revenue calculations include only **completed orders** (status = 'completed').
- Unit price used is `order_items.unit_price` — the actual price at time of purchase, not the product list price.
- Cohorts defined by first completed purchase month using `ROW_NUMBER()` window function.
- Moving averages computed using `ROWS BETWEEN` window frames on daily revenue.
- Growth rates computed using `LAG()` window function over monthly and quarterly aggregates.
