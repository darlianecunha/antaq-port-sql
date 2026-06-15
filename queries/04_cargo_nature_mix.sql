-- Indicator: cargo nature mix per port (share of solid/liquid bulk, containers, general)
-- Technique: conditional aggregation (CASE) + ratios
SELECT p.port_name,
       ROUND(100.0 * SUM(CASE WHEN m.cargo_nature = 'granel solido'   THEN m.tonnes ELSE 0 END) / SUM(m.tonnes), 1) AS pct_solid_bulk,
       ROUND(100.0 * SUM(CASE WHEN m.cargo_nature = 'granel liquido'  THEN m.tonnes ELSE 0 END) / SUM(m.tonnes), 1) AS pct_liquid_bulk,
       ROUND(100.0 * SUM(CASE WHEN m.cargo_nature = 'conteinerizada'  THEN m.tonnes ELSE 0 END) / SUM(m.tonnes), 1) AS pct_container,
       ROUND(100.0 * SUM(CASE WHEN m.cargo_nature = 'carga geral'     THEN m.tonnes ELSE 0 END) / SUM(m.tonnes), 1) AS pct_general
FROM fato_movimentacao m
JOIN fato_atracacao a ON a.berthing_id = m.berthing_id
JOIN dim_porto      p ON p.port_id     = a.port_id
GROUP BY p.port_name
ORDER BY p.port_name;
