CREATE DATABASE fintech_churn;
USE fintech_churn;
SELECT COUNT(*) FROM fintech_churn_excel_analysis;

/*Overall Churn Rate*/
SELECT
    COUNT(*) AS total_customers,
    SUM(Exited) AS churned_customers,
    ROUND(SUM(Exited)*100.0/COUNT(*),2) AS churn_rate_pct
FROM fintech_churn_excel_analysis;

/*Churn by Geography*/
SELECT
    Geography,
    COUNT(*) AS total,
    SUM(Exited) AS churned,
    ROUND(SUM(Exited)*100.0/COUNT(*),2) AS churn_rate_pct
FROM fintech_churn_excel_analysis
GROUP BY Geography
ORDER BY churn_rate_pct DESC;

/*Churn by Gender*/
SELECT
    Gender,
    COUNT(*) AS total,
    SUM(Exited) AS churned,
    ROUND(SUM(Exited)*100.0/COUNT(*),2) AS churn_rate_pct
FROM fintech_churn_excel_analysis
GROUP BY Gender
ORDER BY churn_rate_pct DESC;

/*Churn by Active Status*/
SELECT
CASE WHEN IsActiveMember = 1 THEN 'Active'
ELSE 'Inactive'
    END AS member_status,
    COUNT(*) AS total,
    SUM(Exited) AS churned,
    ROUND(SUM(Exited)*100.0/COUNT(*),2) AS churn_rate_pct
FROM fintech_churn_excel_analysis
GROUP BY IsActiveMember
ORDER BY churn_rate_pct DESC;

/*Churn by Number of Products*/
SELECT
    NumOfProducts,
    COUNT(*) AS total,
    SUM(Exited) AS churned,
    ROUND(SUM(Exited)*100.0/COUNT(*),2) AS churn_rate_pct
FROM fintech_churn_excel_analysis
GROUP BY NumOfProducts
ORDER BY NumOfProducts;

/*Average Balance: Churned vs Retained*/
SELECT
    CASE
        WHEN Exited = 1 THEN 'Churned'
        ELSE 'Retained'
    END AS customer_status,
    ROUND(AVG(Balance),0) AS avg_balance,
    ROUND(AVG(CreditScore),0) AS avg_credit_score,
    ROUND(AVG(EstimatedSalary),0) AS avg_salary
FROM fintech_churn_excel_analysis
GROUP BY Exited;

/*Churn by Age Group*/
SELECT
    CASE
        WHEN Age < 30 THEN '18-29'
        WHEN Age < 40 THEN '30-39'
        WHEN Age < 50 THEN '40-49'
        WHEN Age < 60 THEN '50-59'
        ELSE '60+'
    END AS age_group,
    COUNT(*) AS total,
    SUM(Exited) AS churned,
    ROUND(SUM(Exited)*100.0/COUNT(*),2) AS churn_rate_pct
FROM fintech_churn_excel_analysis
GROUP BY age_group
ORDER BY churn_rate_pct DESC;

/*At-Risk Customer List*/
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
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Exited = 0 THEN 1 ELSE 0 END) AS retained,
    ROUND(
        SUM(CASE WHEN Exited = 0 THEN 1 ELSE 0 END)
        *100.0/COUNT(*),2
    ) AS retention_rate
FROM fintech_churn_excel_analysis
GROUP BY Tenure
ORDER BY Tenure;

/*Geography + Gender Cross Analysis*/
SELECT
    Geography,
    Gender,
    COUNT(*) AS total,
    SUM(Exited) AS churned,
    ROUND(SUM(Exited)*100.0/COUNT(*),2) AS churn_rate_pct
FROM fintech_churn_excel_analysis
GROUP BY Geography, Gender
ORDER BY churn_rate_pct DESC;

/* RFM Segments*/
SELECT
    CustomerId,
    transaction_frequency,
    avg_txn_value,
    monthly_txn_volume,
    NTILE(4) OVER (
        ORDER BY transaction_frequency DESC
    ) AS frequency_score,
    NTILE(4) OVER (
        ORDER BY avg_txn_value DESC
    ) AS monetary_score
FROM fintech_churn_excel_analysis;

/*ROI Calculator*/
WITH risk AS (
    SELECT
        COUNT(*) AS customers,
        SUM(monthly_txn_volume) AS revenue_at_risk
    FROM fintech_churn_excel_analysis
    WHERE Risk_Segment = 'High Risk')
SELECT
    customers,
    revenue_at_risk,
    ROUND(revenue_at_risk*0.20,0) AS revenue_saved,
    ROUND(customers*15,0) AS campaign_cost,
    ROUND(
	(revenue_at_risk*0.20)/(customers*15),
        2) AS roi FROM risk;

/*CEO Summary Dashboard*/
SELECT 'Total Customers' AS metric,
COUNT(*) AS value
FROM fintech_churn_excel_analysis

UNION ALL

SELECT 'Churned Customers',
SUM(Exited)
FROM fintech_churn_excel_analysis

UNION ALL

SELECT 'Churn Rate (%)',
ROUND(SUM(Exited)*100.0/COUNT(*),2)
FROM fintech_churn_excel_analysis

UNION ALL

SELECT 'Inactive Customers',
COUNT(*)
FROM fintech_churn_excel_analysis
WHERE IsActiveMember = 0

UNION ALL

SELECT 'Single Product Customers',
COUNT(*)
FROM fintech_churn_excel_analysis
WHERE NumOfProducts = 1;










































