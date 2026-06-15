-- Indicator: monthly berthings with 3-month moving average (seasonality), 2024
-- Technique: window frame (AVG OVER ... ROWS BETWEEN)
WITH monthly AS (
    SELECT a.berth_month AS month,
           COUNT(*)      AS berthings
    FROM fato_atracacao a
    WHERE a.berth_year = 2024
    GROUP BY a.berth_month
)
SELECT month,
       berthings,
       ROUND(AVG(berthings) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 1) AS moving_avg_3m
FROM monthly
ORDER BY month;
