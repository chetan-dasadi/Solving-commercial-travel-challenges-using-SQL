# Fly-Analytics: Flight Marketing Performance, Pricing Experiments & Cross-Sell Optimization Hub

Welcome to **Fly-Analytics**, an end-to-end SQL data analytics portfolio framework designed to mirror the actual data challenges managed within Online Travel Agencies (OTAs). 

This project simulates a high-volume travel data ecosystem to evaluate **Performance Marketing ROI**, evaluate **Dynamic Pricing A/B Tests**, and track **Ecosystem Cross-Selling (Flight-to-Hotel attachment rates)**.

---

## 🏢 Business Context & Core Focus
In the modern OTA ecosystem, profit scaling relies on two high-leverage activities: optimizing acquisition costs across fragmented metasearch channels (e.g., Google Flights, Skyscanner) and unlocking multi-product margins through intelligent lodging attachment frameworks.

This framework applies advanced SQL queries to process and analyze massive relational transaction logs to extract immediate, actionable commercial insights.

---

## 🗂️ Database Schema Architecture
The database structure relies on standard PostgreSQL constraints and relational foreign keys, utilizing indexing strategy to ensure performance efficiency across high-frequency marketing and booking tables.

*   `marketing_clicks`: Tracks performance marketing acquisition traffic, entry paths, and distinct cost-per-click metrics.
*   `pricing_experiments`: Maps specific visitor sessions to active pricing A/B test splits (`Control` vs `Treatment`).
*   `flight_searches`: Captures raw user search intent and high-traffic routing corridors.
*   `flight_bookings`: Records verified flight conversions, revenue totals, and ancillary monetization checkpoints.
*   `hotel_bookings`: Records downstream property bookings utilized for measuring ecosystem cross-sell metrics.

---

## 📊 Analytical Deep-Dives Solved

### 1. Metasearch Attribution & Return on Ad Spend (ROAS)
*   **Commercial Objective:** Identify which traffic-acquisition avenues are burning marketing budget versus which paths generate real, high-margin booking volume.
*   **SQL Blueprint:** Employs conditional aggregations and left joins to evaluate unique clicks against closed transactional ledger logs, deriving live conversion and ROAS thresholds.

### 2. Dynamic Pricing Framework Experiment (A/B Test Evaluation)
*   **Commercial Objective:** Measure the directional revenue and conversion rate impact of a newly deployed dynamic pricing markup framework versus historical baseline thresholds.
*   **SQL Blueprint:** Segregates high-frequency log metrics by experiment variant tokens to monitor changes in Average Order Value (AOV) and gross margin fluctuations.

### 3. Flight-to-Hotel Cross-Sell ("Attachment Rate") Analysis
*   **Commercial Objective:** Maximize total user lifetime value by analyzing the rate at which cross-functional flight purchasers convert to internal hotel listings within a strict 48-hour window.
*   **SQL Blueprint:** Utilizes window logic and complex interval-based self-joins to connect isolated product transaction paths across identical travel destination corridors.

---

## 🛠️ Tech Stack & Implementation Details
*   **Dialect:** PostgreSQL (Structured schema definitions, multi-column indexes, and arithmetic intervals).
*   **Architecture Pattern:** Relational Star/Snowflake hybrid designed to optimize click-stream attribution paths.

---

## 🚀 How to Run & Explore
1. Clone the repository to your local environment.
2. Run `/scripts/schema_ddl.sql` to instantiate tables, structural keys, and optimization indexes.
3. Execute the target analysis found within `/scripts/business_queries.sql` to pull live tracking insights.

---
**Developed by Chetan Kumar D**  
*Data & Strategy Analyst | Flights BI Specialist*  
[LinkedIn Portfolio](https://linkedin.com/in/chetan-dasadi) • [Email Contact](mailto:chetan.dasadi@gmail.com)
