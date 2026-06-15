-- Indicator: average berthing (dwell) time by port and year (cf. LABTRANS tempos médios)
-- Technique: AVG, GROUP BY
SELECT p.port_name,
       a.berth_year,
       ROUND(AVG(a.berth_hours), 1) AS avg_berth_hours,
       COUNT(*)                     AS n_berthings
FROM fato_atracacao a
JOIN dim_porto p ON p.port_id = a.port_id
GROUP BY p.port_name, a.berth_year
ORDER BY p.port_name, a.berth_year;
