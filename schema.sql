-- antaq-port-sql: star schema for Brazilian port operations (ANTAQ-style)
-- Dimensions
CREATE TABLE IF NOT EXISTS dim_porto (
    port_id     INTEGER PRIMARY KEY,
    port_name   VARCHAR,
    state       VARCHAR,
    port_type   VARCHAR
);

CREATE TABLE IF NOT EXISTS dim_navio (
    vessel_id   INTEGER PRIMARY KEY,
    imo         INTEGER,
    vessel_name VARCHAR,
    vessel_type VARCHAR,
    dwt         INTEGER
);

-- Fact: berthings (atracações)
CREATE TABLE IF NOT EXISTS fato_atracacao (
    berthing_id INTEGER PRIMARY KEY,
    port_id     INTEGER REFERENCES dim_porto(port_id),
    vessel_id   INTEGER REFERENCES dim_navio(vessel_id),
    berth_start TIMESTAMP,
    berth_end   TIMESTAMP,
    -- derived: dwell time in hours
    berth_hours DOUBLE,
    berth_year  INTEGER,
    berth_month INTEGER
);

-- Fact: cargo movements (movimentação)
CREATE TABLE IF NOT EXISTS fato_movimentacao (
    movement_id   INTEGER PRIMARY KEY,
    berthing_id   INTEGER REFERENCES fato_atracacao(berthing_id),
    cargo_type    VARCHAR,
    cargo_nature  VARCHAR,   -- granel solido / granel liquido / conteinerizada / carga geral
    tonnes        DOUBLE,
    direction     VARCHAR    -- export / import / cabotage
);
