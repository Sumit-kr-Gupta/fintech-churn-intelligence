/*==========================================================
PROJECT  : Fintech Customer Churn Intelligence
DATABASE : fintech_churn

OBJECTIVE: Analyze customer churn behavior, identify at-risk segments,
quantify revenue impact, and support retention strategy decisions
through descriptive, diagnostic, and strategic SQL analysis.

CONTENTS:
  SECTION 0  - Database Setup
  SECTION 1  - Descriptive & Exploratory Analysis
  SECTION 2  - Diagnostic & Segmentation Analysis
  SECTION 3  - Strategic & Decision-Support Analysis
==========================================================*/


/*==========================================================
SECTION 0 — DATABASE SETUP
Business Goal:
  Initialize the database and confirm the source table is
  present and populated before any analysis is trusted.
Business Questions:
  1. Does the database exist?
  2. Is the source table populated with data?
==========================================================*/
CREATE DATABASE IF NOT EXISTS fintech_churn;
USE fintech_churn;

/*Row Count Check*/
SELECT COUNT(*) AS row_count
FROM fintech_churn_excel_analysis;

/*==========================================================
SECTION 1 — DESCRIPTIVE & EXPLORATORY ANALYSIS
Business Goal:
  Establish the baseline facts — how many customers churn,
  and how that rate breaks down across single dimensions
  (geography, gender, activity, products, balance, age).
Business Questions:
  1. What is the overall churn rate?
  2. Which geography, gender, or age group churns the most?
  3. Does activity status or number of products held affect churn?
  4. Are churned customers financially different from retained ones?
==========================================================*/
/*Overall Churn Rate*/
SELECT COUNT(*) AS total_customers,
    SUM(Exited) AS churned_customers,
    ROUND(SUM(Exited) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM fintech_churn_excel_analysis;

/*Churn by Geography*/
SELECT Geography,
    COUNT(*) AS total,
    SUM(Exited) AS churned,
    ROUND(SUM(Exited) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM fintech_churn_excel_analysis
GROUP BY Geography
ORDER BY churn_rate_pct DESC;

/*Churn by Gender*/
SELECT Gender,
    COUNT(*) AS total,
    SUM(Exited) AS churned,
    ROUND(SUM(Exited) * 100.0 / COUNT(*), 2)   AS churn_rate_pct
FROM fintech_churn_excel_analysis
GROUP BY Gender
ORDER BY churn_rate_pct DESC;

/*Churn by Active Membership Status*/
SELECT CASE
WHEN IsActiveMember = 1 THEN 'Active'
ELSE 'Inactive'
END AS member_status,
COUNT(*) AS total,
SUM(Exited) AS churned,
ROUND(SUM(Exited) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM fintech_churn_excel_analysis
GROUP BY member_status
ORDER BY churn_rate_pct DESC;

/*Churn by Number of Products Held*/
SELECT NumOfProducts,
COUNT(*) AS total,
SUM(Exited) AS churned,
ROUND(SUM(Exited) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM fintech_churn_excel_analysis
GROUP BY NumOfProducts
ORDER BY NumOfProducts;

/*Average Balance, Credit Score & Salary — Churned vs Retained*/
SELECT CASE 
WHEN Exited = 1 THEN 'Churned'
ELSE 'Retained'
END                                         AS customer_status,
ROUND(AVG(Balance), 0)                     AS avg_balance,
ROUND(AVG(CreditScore), 0)                 AS avg_credit_score,
    ROUND(AVG(EstimatedSalary), 0)             AS avg_salary
FROM fintech_churn_excel_analysis
GROUP BY customer_status;

/*Churn by Age Group*/
SELECT
    CASE
        WHEN Age < 30 THEN '18-29'
        WHEN Age < 40 THEN '30-39'
        WHEN Age < 50 THEN '40-49'
        WHEN Age < 60 THEN '50-59'
        ELSE '60+'
    END                                         AS age_group,
    COUNT(*)                                   AS total,
    SUM(Exited)                                AS churned,
    ROUND(SUM(Exited) * 100.0 / COUNT(*), 2)   AS churn_rate_pct
FROM fintech_churn_excel_analysis
GROUP BY age_group
ORDER BY churn_rate_pct DESC;


/*==========================================================
SECTION 2 — DIAGNOSTIC & SEGMENTATION ANALYSIS
Business Goal:
  Move from "what is happening" to "who exactly is at risk"
  by combining dimensions and producing actionable,
  customer-level targeting lists.
Business Questions:
  1. Which retained customers show the same warning signs as
     customers who already churned, and deserve outreach?
  2. Does retention improve the longer a customer stays (Tenure)?
  3. Do specific geography + gender combinations stand out as
     extreme high- or low-churn segments?
==========================================================*/

/*At-Risk Customer List (Actionable Targeting List)*/
SELECT
    CustomerId,
    Age,
    Geography,
    Gender,
    Balance,
    Tenure,
    NumOfProducts,
    IsActiveMember
FROM fintech_churn_excel_analysis
WHERE Exited = 0
  AND IsActiveMember = 0
  AND NumOfProducts = 1
ORDER BY Balance DESC
LIMIT 100;

/*Cohort Retention by Tenure*/
SELECT
    Tenure,
    COUNT(*)                                                       AS total_customers,
    SUM(CASE WHEN Exited = 0 THEN 1 ELSE 0 END)                    AS retained,
    ROUND(
        SUM(CASE WHEN Exited = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    )                                                               AS retention_rate_pct
FROM fintech_churn_excel_analysis
GROUP BY Tenure
ORDER BY Tenure;

/*Geography + Gender Cross Analysis*/
SELECT
    Geography,
    Gender,
    COUNT(*)                                   AS total,
    SUM(Exited)                                AS churned,
    ROUND(SUM(Exited) * 100.0 / COUNT(*), 2)   AS churn_rate_pct
FROM fintech_churn_excel_analysis
GROUP BY Geography, Gender
ORDER BY churn_rate_pct DESC;


/*==========================================================
SECTION 3 — STRATEGIC & DECISION-SUPPORT ANALYSIS
Business Goal:
  Translate churn patterns into financial and strategic
  decisions — customer value segmentation (RFM), a quantified
  ROI case for retention spend, and an executive KPI summary.
Business Questions:
  1. Which customers are most valuable based on transaction
     frequency and monetary value?
  2. Is a targeted retention campaign financially worth running?
  3. What is the single-glance churn health scorecard for
     leadership review?
==========================================================*/

/*RFM-Style Customer Segmentation (Frequency & Monetary)*/
SELECT
    CustomerId,
    transaction_frequency,
    avg_txn_value,
    monthly_txn_volume,
    NTILE(4) OVER (ORDER BY transaction_frequency DESC)    AS frequency_score,
    NTILE(4) OVER (ORDER BY avg_txn_value DESC)            AS monetary_score,
    CONCAT(
        NTILE(4) OVER (ORDER BY transaction_frequency DESC),
        '-',
        NTILE(4) OVER (ORDER BY avg_txn_value DESC)
    )                                                       AS fm_segment
FROM fintech_churn_excel_analysis;

/*Revenue-at-Risk & Retention Campaign ROI Calculator*/
WITH risk AS (
    SELECT
        COUNT(*)                   AS customers,
        SUM(monthly_txn_volume)    AS revenue_at_risk
    FROM fintech_churn_excel_analysis
    WHERE Risk_Segment = 'High Risk'
)
SELECT
    customers,
    revenue_at_risk,
    ROUND(revenue_at_risk * 0.20, 0)                           AS revenue_saved,
    ROUND(customers * 15, 0)                                   AS campaign_cost,
    ROUND((revenue_at_risk * 0.20) / (customers * 15), 2)      AS roi
FROM risk;

/*Executive KPI Summary Dashboard*/
SELECT
    'Total Customers'          AS metric,
    COUNT(*)                   AS value
FROM fintech_churn_excel_analysis

UNION ALL

SELECT
    'Churned Customers',
    SUM(Exited)
FROM fintech_churn_excel_analysis
UNION ALL
SELECT
    'Churn Rate (%)',
    ROUND(SUM(Exited) * 100.0 / COUNT(*), 2)
FROM fintech_churn_excel_analysis
UNION ALL
SELECT
    'Inactive Customers',
    COUNT(*)
FROM fintech_churn_excel_analysis
WHERE IsActiveMember = 0
UNION ALL
SELECT
    'Single-Product Customers',
    COUNT(*)
FROM fintech_churn_excel_analysis
WHERE NumOfProducts = 1;
