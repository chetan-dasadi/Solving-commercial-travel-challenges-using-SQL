-- ============================================================
-- Fly-Analytics: Business Queries
-- Dialect: PostgreSQL
-- Companion to schema_ddl.sql
-- ============================================================

-- ============================================================
-- 1. METASEARCH ATTRIBUTION & RETURN ON AD SPEND (ROAS)
-- Objective: identify which channels burn budget vs. drive
-- high-margin bookings.
-- ============================================================

WITH channel_spend AS (
    SELECT
        channel,
        COUNT(*)                    AS total_clicks,
        SUM(cost_per_click)         AS total_spend
    FROM marketing_clicks
    GROUP BY channel
),
channel_bookings AS (
    SELECT
        mc.channel,
        COUNT(DISTINCT fb.booking_id) AS total_bookings,
        SUM(fb.total_revenue)         AS total_revenue
    FROM marketing_clicks mc
    LEFT JOIN flight_bookings fb
        ON fb.session_id = mc.session_id
        AND fb.booking_timestamp >= mc.click_timestamp
    GROUP BY mc.channel
)
SELECT
    cs.channel,
    cs.total_clicks,
    cs.total_spend,
    COALESCE(cb.total_bookings, 0)                              AS total_bookings,
    COALESCE(cb.total_revenue, 0)                                AS total_revenue,
    ROUND(COALESCE(cb.total_bookings, 0)::NUMERIC / NULLIF(cs.total_clicks, 0) * 100, 2) AS conversion_rate_pct,
    ROUND(COALESCE(cb.total_revenue, 0) / NULLIF(cs.total_spend, 0), 2)                   AS roas
FROM channel_spend cs
LEFT JOIN channel_bookings cb ON cb.channel = cs.channel
ORDER BY roas DESC NULLS LAST;


-- ============================================================
-- 2. DYNAMIC PRICING FRAMEWORK EXPERIMENT (A/B TEST EVALUATION)
-- Objective: measure revenue / conversion impact of Treatment
-- vs Control pricing variant.
-- ============================================================

WITH variant_sessions AS (
    SELECT session_id, variant
    FROM pricing_experiments
),
variant_bookings AS (
    SELECT
        vs.variant,
        COUNT(DISTINCT vs.session_id)          AS sessions_in_variant,
        COUNT(DISTINCT fb.booking_id)          AS bookings,
        SUM(fb.total_revenue)                  AS total_revenue,
        AVG(fb.total_revenue)                  AS avg_order_value
    FROM variant_sessions vs
    LEFT JOIN flight_bookings fb ON fb.session_id = vs.session_id
    GROUP BY vs.variant
)
SELECT
    variant,
    sessions_in_variant,
    bookings,
    ROUND(bookings::NUMERIC / NULLIF(sessions_in_variant, 0) * 100, 2) AS conversion_rate_pct,
    ROUND(COALESCE(total_revenue, 0), 2)                                AS total_revenue,
    ROUND(COALESCE(avg_order_value, 0), 2)                              AS avg_order_value
FROM variant_bookings
ORDER BY variant;

-- Lift of Treatment over Control (AOV and conversion)
WITH variant_sessions AS (
    SELECT session_id, variant FROM pricing_experiments
),
variant_bookings AS (
    SELECT
        vs.variant,
        COUNT(DISTINCT vs.session_id) AS sessions_in_variant,
        COUNT(DISTINCT fb.booking_id) AS bookings,
        AVG(fb.total_revenue)         AS avg_order_value
    FROM variant_sessions vs
    LEFT JOIN flight_bookings fb ON fb.session_id = vs.session_id
    GROUP BY vs.variant
)
SELECT
    ROUND(
        (MAX(CASE WHEN variant = 'Treatment' THEN avg_order_value END)
         - MAX(CASE WHEN variant = 'Control' THEN avg_order_value END))
        / NULLIF(MAX(CASE WHEN variant = 'Control' THEN avg_order_value END), 0) * 100, 2
    ) AS aov_lift_pct,
    ROUND(
        (MAX(CASE WHEN variant = 'Treatment' THEN bookings::NUMERIC / NULLIF(sessions_in_variant,0) END)
         - MAX(CASE WHEN variant = 'Control' THEN bookings::NUMERIC / NULLIF(sessions_in_variant,0) END))
        * 100, 2
    ) AS conversion_lift_pp
FROM variant_bookings;


-- ============================================================
-- 3. FLIGHT-TO-HOTEL CROSS-SELL ("ATTACHMENT RATE") ANALYSIS
-- Objective: measure the share of flight purchasers who also
-- book a hotel in the same destination within 48 hours.
-- ============================================================

WITH flight_purchases AS (
    SELECT
        booking_id,
        user_id,
        destination_city,
        booking_timestamp AS flight_booking_ts
    FROM flight_bookings
),
attached_hotels AS (
    SELECT
        fp.booking_id,
        fp.user_id,
        fp.destination_city,
        MIN(hb.booking_timestamp) AS hotel_booking_ts
    FROM flight_purchases fp
    JOIN hotel_bookings hb
        ON hb.user_id = fp.user_id
        AND hb.destination_city = fp.destination_city
        AND hb.booking_timestamp BETWEEN fp.flight_booking_ts
            AND fp.flight_booking_ts + INTERVAL '48 hours'
    GROUP BY fp.booking_id, fp.user_id, fp.destination_city
)
SELECT
    COUNT(DISTINCT fp.booking_id)                                   AS total_flight_bookings,
    COUNT(DISTINCT ah.booking_id)                                   AS attached_hotel_bookings,
    ROUND(
        COUNT(DISTINCT ah.booking_id)::NUMERIC
        / NULLIF(COUNT(DISTINCT fp.booking_id), 0) * 100, 2
    )                                                                AS attachment_rate_pct
FROM flight_purchases fp
LEFT JOIN attached_hotels ah ON ah.booking_id = fp.booking_id;

-- Attachment rate broken down by destination city
WITH flight_purchases AS (
    SELECT booking_id, user_id, destination_city, booking_timestamp AS flight_booking_ts
    FROM flight_bookings
),
attached_hotels AS (
    SELECT fp.booking_id, fp.destination_city
    FROM flight_purchases fp
    JOIN hotel_bookings hb
        ON hb.user_id = fp.user_id
        AND hb.destination_city = fp.destination_city
        AND hb.booking_timestamp BETWEEN fp.flight_booking_ts
            AND fp.flight_booking_ts + INTERVAL '48 hours'
)
SELECT
    fp.destination_city,
    COUNT(DISTINCT fp.booking_id)                                  AS total_flight_bookings,
    COUNT(DISTINCT ah.booking_id)                                  AS attached_hotel_bookings,
    ROUND(
        COUNT(DISTINCT ah.booking_id)::NUMERIC
        / NULLIF(COUNT(DISTINCT fp.booking_id), 0) * 100, 2
    )                                                               AS attachment_rate_pct
FROM flight_purchases fp
LEFT JOIN attached_hotels ah ON ah.booking_id = fp.booking_id
GROUP BY fp.destination_city
ORDER BY attachment_rate_pct DESC;
