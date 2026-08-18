-- ============================================================
-- Fly-Analytics: Sample Seed Data
-- Optional — run after schema_ddl.sql to test business_queries.sql
-- ============================================================

INSERT INTO marketing_clicks (session_id, channel, campaign_name, cost_per_click, click_timestamp, device_type) VALUES
('sess_001', 'Google Flights', 'GF_Brand_Search', 1.20, '2026-06-01 08:00:00', 'mobile'),
('sess_002', 'Skyscanner', 'SK_Metasearch_Q2', 0.85, '2026-06-01 09:15:00', 'desktop'),
('sess_003', 'Direct', NULL, 0.00, '2026-06-01 10:05:00', 'desktop'),
('sess_004', 'Google Flights', 'GF_Retargeting', 1.05, '2026-06-02 11:30:00', 'mobile'),
('sess_005', 'Skyscanner', 'SK_Metasearch_Q2', 0.90, '2026-06-02 12:45:00', 'tablet');

INSERT INTO pricing_experiments (session_id, experiment_name, variant, assigned_at) VALUES
('sess_001', 'dynamic_markup_v1', 'Control',   '2026-06-01 08:00:05'),
('sess_002', 'dynamic_markup_v1', 'Treatment', '2026-06-01 09:15:05'),
('sess_003', 'dynamic_markup_v1', 'Control',   '2026-06-01 10:05:05'),
('sess_004', 'dynamic_markup_v1', 'Treatment', '2026-06-02 11:30:05'),
('sess_005', 'dynamic_markup_v1', 'Treatment', '2026-06-02 12:45:05');

INSERT INTO flight_searches (session_id, origin_city, destination_city, search_timestamp, passengers, trip_type) VALUES
('sess_001', 'Hyderabad', 'Singapore', '2026-06-01 08:02:00', 1, 'round-trip'),
('sess_002', 'Mumbai',    'Bangkok',   '2026-06-01 09:17:00', 2, 'round-trip'),
('sess_003', 'Delhi',     'Dubai',     '2026-06-01 10:07:00', 1, 'one-way'),
('sess_004', 'Hyderabad', 'Singapore', '2026-06-02 11:32:00', 1, 'round-trip'),
('sess_005', 'Chennai',   'Bangkok',   '2026-06-02 12:47:00', 3, 'round-trip');

INSERT INTO flight_bookings (session_id, user_id, origin_city, destination_city, booking_timestamp, base_fare, ancillary_revenue) VALUES
('sess_001', 101, 'Hyderabad', 'Singapore', '2026-06-01 08:20:00', 320.00, 45.00),
('sess_002', 102, 'Mumbai',    'Bangkok',   '2026-06-01 09:40:00', 210.00, 15.00),
('sess_004', 103, 'Hyderabad', 'Singapore', '2026-06-02 11:50:00', 335.00, 60.00),
('sess_005', 104, 'Chennai',   'Bangkok',   '2026-06-02 13:10:00', 640.00, 90.00);

INSERT INTO hotel_bookings (user_id, destination_city, booking_timestamp, nightly_rate, nights) VALUES
(101, 'Singapore', '2026-06-01 20:00:00', 140.00, 3),
(103, 'Singapore', '2026-06-04 09:00:00', 150.00, 2),  -- outside 48h window (attachment should not count)
(104, 'Bangkok',   '2026-06-02 18:00:00', 90.00,  4);
