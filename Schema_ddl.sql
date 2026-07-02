-- ==========================================
-- FLY-ANALYTICS: DATABASE SCHEMA
-- Target Role: Analyst, Flight Marketing
-- ==========================================

-- Drop tables if they exist to allow easy re-running/testing
DROP TABLE IF EXISTS hotel_bookings CASCADE;
DROP TABLE IF EXISTS flight_bookings CASCADE;
DROP TABLE IF EXISTS flight_searches CASCADE;
DROP TABLE IF EXISTS pricing_experiments CASCADE;
DROP TABLE IF EXISTS marketing_clicks CASCADE;

-- 1. MARKETING CLICKS TABLE
-- Tracks user acquisition traffic incoming from performance marketing channels
CREATE TABLE marketing_clicks (
    click_id SERIAL PRIMARY KEY,
    user_session_id VARCHAR(50) NOT NULL UNIQUE,
    channel_name VARCHAR(50) NOT NULL, -- e.g., 'Google Flights', 'Skyscanner', 'TripAdvisor', 'Paid Ads'
    click_timestamp TIMESTAMP NOT NULL,
    click_cost NUMERIC(10, 4) NOT NULL CHECK (click_cost >= 0) -- Cost per click (CPC) in USD
);

-- 2. PRICING EXPERIMENTS TABLE
-- Maps user sessions to randomized dynamic pricing A/B test variants
CREATE TABLE pricing_experiments (
    session_id VARCHAR(50) PRIMARY KEY,
    user_id INT NOT NULL,
    variant_name VARCHAR(20) NOT NULL, -- e.g., 'Control', 'Treatment_B'
    assignment_timestamp TIMESTAMP NOT NULL,
    FOREIGN KEY (session_id) REFERENCES marketing_clicks(user_session_id) ON DELETE CASCADE
);

-- 3. FLIGHT SEARCHES TABLE
-- Records explicit search intent, routing, and corridors explored by users
CREATE TABLE flight_searches (
    search_id SERIAL PRIMARY KEY,
    user_session_id VARCHAR(50) NOT NULL,
    user_id INT NOT NULL,
    origin_city VARCHAR(50) NOT NULL,
    destination_city VARCHAR(50) NOT NULL,
    search_timestamp TIMESTAMP NOT NULL,
    FOREIGN KEY (user_session_id) REFERENCES marketing_clicks(user_session_id) ON DELETE CASCADE
);

-- 4. FLIGHT BOOKINGS TABLE
-- Records successful conversion checkpoints, fare totals, and ancillary monetization streams
CREATE TABLE flight_bookings (
    booking_id SERIAL PRIMARY KEY,
    user_session_id VARCHAR(50) NOT NULL,
    user_id INT NOT NULL,
    origin_city VARCHAR(50) NOT NULL,
    destination_city VARCHAR(50) NOT NULL,
    flight_type VARCHAR(20) NOT NULL CHECK (flight_type IN ('Domestic', 'International')),
    total_fare NUMERIC(10, 2) NOT NULL CHECK (total_fare > 0),
    ancillary_revenue NUMERIC(10, 2) DEFAULT 0.00 CHECK (ancillary_revenue >= 0), -- e.g., baggage, seat selection
    booking_timestamp TIMESTAMP NOT NULL,
    FOREIGN KEY (user_session_id) REFERENCES marketing_clicks(user_session_id) ON DELETE CASCADE
);

-- 5. HOTEL BOOKINGS TABLE
-- Tracks downstream property stays used to calculate ecosystem cross-sell/attachment rates
CREATE TABLE hotel_bookings (
    booking_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    city VARCHAR(50) NOT NULL,
    total_spent NUMERIC(10, 2) NOT NULL CHECK (total_spent > 0),
    booking_timestamp TIMESTAMP NOT NULL
);

-- ==========================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- (Shows recruiters you care about query efficiency on "massive data sets")
-- ==========================================
CREATE INDEX idx_clicks_channel ON marketing_clicks(channel_name);
CREATE INDEX idx_experiments_variant ON pricing_experiments(variant_name);
CREATE INDEX idx_flights_destination ON flight_bookings(destination_city);
CREATE INDEX idx_flights_user_time ON flight_bookings(user_id, booking_timestamp);
CREATE INDEX idx_hotels_user_time ON hotel_bookings(user_id, booking_timestamp);
