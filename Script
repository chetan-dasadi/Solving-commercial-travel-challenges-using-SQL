-- ============================================================
-- Fly-Analytics: Schema DDL
-- Dialect: PostgreSQL
-- Description: Relational schema for OTA marketing, pricing
--              experiments, flight bookings, and hotel cross-sell
-- ============================================================

DROP TABLE IF EXISTS hotel_bookings CASCADE;
DROP TABLE IF EXISTS flight_bookings CASCADE;
DROP TABLE IF EXISTS flight_searches CASCADE;
DROP TABLE IF EXISTS pricing_experiments CASCADE;
DROP TABLE IF EXISTS marketing_clicks CASCADE;

-- ------------------------------------------------------------
-- 1. marketing_clicks
-- Tracks performance-marketing acquisition traffic and cost.
-- ------------------------------------------------------------
CREATE TABLE marketing_clicks (
    click_id        BIGSERIAL PRIMARY KEY,
    session_id      VARCHAR(64) NOT NULL,
    channel         VARCHAR(50) NOT NULL,        -- e.g. Google Flights, Skyscanner, Direct
    campaign_name   VARCHAR(120),
    cost_per_click  NUMERIC(8,4) NOT NULL CHECK (cost_per_click >= 0),
    click_timestamp TIMESTAMP NOT NULL,
    device_type     VARCHAR(20)                  -- desktop, mobile, tablet
);

CREATE INDEX idx_marketing_clicks_session ON marketing_clicks (session_id);
CREATE INDEX idx_marketing_clicks_channel_ts ON marketing_clicks (channel, click_timestamp);

-- ------------------------------------------------------------
-- 2. pricing_experiments
-- Maps sessions to active A/B pricing test variants.
-- ------------------------------------------------------------
CREATE TABLE pricing_experiments (
    experiment_id    BIGSERIAL PRIMARY KEY,
    session_id       VARCHAR(64) NOT NULL,
    experiment_name  VARCHAR(120) NOT NULL,
    variant          VARCHAR(20) NOT NULL CHECK (variant IN ('Control', 'Treatment')),
    assigned_at      TIMESTAMP NOT NULL
);

CREATE INDEX idx_pricing_experiments_session ON pricing_experiments (session_id);
CREATE INDEX idx_pricing_experiments_variant ON pricing_experiments (experiment_name, variant);

-- ------------------------------------------------------------
-- 3. flight_searches
-- Raw user search intent and routing corridors.
-- ------------------------------------------------------------
CREATE TABLE flight_searches (
    search_id       BIGSERIAL PRIMARY KEY,
    session_id      VARCHAR(64) NOT NULL,
    origin_city     VARCHAR(80) NOT NULL,
    destination_city VARCHAR(80) NOT NULL,
    search_timestamp TIMESTAMP NOT NULL,
    passengers      SMALLINT DEFAULT 1 CHECK (passengers > 0),
    trip_type       VARCHAR(20)                  -- one-way, round-trip
);

CREATE INDEX idx_flight_searches_session ON flight_searches (session_id);
CREATE INDEX idx_flight_searches_route ON flight_searches (origin_city, destination_city);

-- ------------------------------------------------------------
-- 4. flight_bookings
-- Verified flight conversions and revenue.
-- ------------------------------------------------------------
CREATE TABLE flight_bookings (
    booking_id       BIGSERIAL PRIMARY KEY,
    session_id       VARCHAR(64) NOT NULL,
    user_id          BIGINT NOT NULL,
    origin_city      VARCHAR(80) NOT NULL,
    destination_city VARCHAR(80) NOT NULL,
    booking_timestamp TIMESTAMP NOT NULL,
    base_fare        NUMERIC(10,2) NOT NULL CHECK (base_fare >= 0),
    ancillary_revenue NUMERIC(10,2) DEFAULT 0 CHECK (ancillary_revenue >= 0),
    total_revenue    NUMERIC(10,2) GENERATED ALWAYS AS (base_fare + ancillary_revenue) STORED
);

CREATE INDEX idx_flight_bookings_session ON flight_bookings (session_id);
CREATE INDEX idx_flight_bookings_user_ts ON flight_bookings (user_id, booking_timestamp);
CREATE INDEX idx_flight_bookings_route ON flight_bookings (origin_city, destination_city);

-- ------------------------------------------------------------
-- 5. hotel_bookings
-- Downstream property bookings for cross-sell measurement.
-- ------------------------------------------------------------
CREATE TABLE hotel_bookings (
    hotel_booking_id  BIGSERIAL PRIMARY KEY,
    user_id            BIGINT NOT NULL,
    destination_city   VARCHAR(80) NOT NULL,
    booking_timestamp  TIMESTAMP NOT NULL,
    nightly_rate       NUMERIC(10,2) NOT NULL CHECK (nightly_rate >= 0),
    nights             SMALLINT NOT NULL CHECK (nights > 0),
    total_revenue      NUMERIC(10,2) GENERATED ALWAYS AS (nightly_rate * nights) STORED
);

CREATE INDEX idx_hotel_bookings_user_ts ON hotel_bookings (user_id, booking_timestamp);
CREATE INDEX idx_hotel_bookings_destination ON hotel_bookings (destination_city);
