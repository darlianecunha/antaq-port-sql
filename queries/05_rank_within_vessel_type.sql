-- Indicator: rank ports by cargo within each vessel type (2024)
-- Technique: RANK() OVER (PARTITION BY ...)
WITH agg AS (
    SELECT v.vessel_type,
           p.port_name,
           SUM(m.tonnes) AS tonnes
    FROM fato_movimentacao m
    JOIN fato_atracacao a ON a.berthing_id = m.berthing_id
    JOIN dim_navio      v ON v.vessel_id   = a.vessel_id
    JOIN dim_porto      p ON p.port_id     = a.port_id
    WHERE a.berth_year = 2024
    GROUP BY v.vessel_type, p.port_name
)
SELECT vessel_type,
       port_name,
       ROUND(tonnes / 1e6, 2) AS million_tonnes,
       RANK() OVER (PARTITION BY vessel_type ORDER BY tonnes DESC) AS rank_in_type
FROM agg
ORDER BY vessel_type, rank_in_type;
