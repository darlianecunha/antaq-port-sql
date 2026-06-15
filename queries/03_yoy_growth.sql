-- Indicator: year-over-year cargo growth per port
-- Technique: CTE + window function LAG() OVER (PARTITION BY ...)
WITH yearly AS (
    SELECT p.port_name,
           a.berth_year,
           SUM(m.tonnes) AS tonnes
    FROM fato_movimentacao m
    JOIN fato_atracacao a ON a.berthing_id = m.berthing_id
    JOIN dim_porto      p ON p.port_id     = a.port_id
    GROUP BY p.port_name, a.berth_year
)
SELECT port_name,
       berth_year,
       ROUND(tonnes / 1e6, 2) AS million_tonnes,
       ROUND(100.0 * (tonnes - LAG(tonnes) OVER (PARTITION BY port_name ORDER BY berth_year))
             / NULLIF(LAG(tonnes) OVER (PARTITION BY port_name ORDER BY berth_year), 0), 1) AS yoy_growth_pct
FROM yearly
ORDER BY port_name, berth_year;
