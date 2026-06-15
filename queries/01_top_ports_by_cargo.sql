-- Indicator: top ports by total cargo moved in 2024 (cf. LABTRANS M7)
-- Technique: JOIN, GROUP BY, ORDER BY, LIMIT
SELECT p.port_name,
       p.state,
       ROUND(SUM(m.tonnes) / 1e6, 2) AS cargo_million_tonnes,
       COUNT(DISTINCT a.berthing_id)  AS berthings
FROM fato_movimentacao m
JOIN fato_atracacao   a ON a.berthing_id = m.berthing_id
JOIN dim_porto        p ON p.port_id     = a.port_id
WHERE a.berth_year = 2024
GROUP BY p.port_name, p.state
ORDER BY cargo_million_tonnes DESC
LIMIT 10;
