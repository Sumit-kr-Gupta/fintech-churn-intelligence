## Fintech Churn Intelligence

End-to-end customer retention analytics system using Excel, SQL, and Python to identify churn drivers, segment at-risk customers, and quantify revenue risk in a fintech environment.

| Domain | Tools | Dataset | Industry |
|---|---|---|---|
| Customer Analytics | Excel · SQL · Python · Tableau *(Coming Soon)* | 10,000 customers · 22 features | Financial Services / Fintech |

---
## The Business Problem
A fintech platform is losing **20.37% of its customers annually** — roughly 1 in 5 customers leaves every year. In financial services, a churned customer is not just a lost monthly fee. It represents the destruction of a relationship that cost money to acquire, carries an average balance of €91,108, and represents long-term lifetime value that never gets realised.

At a 20.37% churn rate across 10,000 customers, 2,037 customers left in the analysis period.Based on their average balance, that represents **€80.94 million in assets at risk of leaving the platform** — capital that supports customer engagement, cross-sell opportunities, and long-term revenue generation., and anchors product cross-sell. That is not a retention problem. That is a revenue problem.

This project answers three questions a CFO or Head of Growth would actually ask:
1. Which customers are most likely to leave next?
2. Why are they leaving — and is it preventable?
3. What is the financial cost of inaction?
---

## Business Objectives
1. Quantify the churn rate and financial exposure at an aggregate and segment level
2. Identify the highest-risk customer segments by geography, age, activity status, and product usage
3. Detect behavioural signals that precede churn using engineered transaction features
4. Build a risk scoring system that produces an actionable customer-level output for CRM and retention teams
5. Train predictive models to estimate customer churn probability and identify at-risk customers.
6. Deliver a ranked at-risk customer list** that a retention team can act on immediately
---

## Dataset Overview

Source: Adapted from the publicly available Bank Customer Churn dataset (Kaggle). Used as a proxy for a fintech platform customer base.

Rows: 10,000 customers  
Original columns: 12  
Engineered columns: 10 (added in Excel for business depth)  
Target variable: `Exited` (1 = churned, 0 = retained)

Data limitations and assumptions:
- The dataset uses a European banking geography (France, Germany, Spain) as a proxy for fintech market segmentation
- Transaction-level features (`transaction_frequency`, `avg_txn_value`, `payment_failure_rate`, `monthly_txn_volume`) were synthetically engineered using realistic distributions, since the base dataset contains only static customer attributes
- `Revenue At Risk` is calculated as: churned customers × average balance of churned segment (€91,108)
- Results are directionally valid for analytical and portfolio purposes; methodology would be refined with live transactional data in a production environment
---

## Data Dictionary
| Column | Type | Business Meaning |
|---|---|---|
| `CustomerId` | ID | Unique customer identifier — dropped from modelling |
| `CreditScore` | Numeric | Creditworthiness proxy; lower scores may indicate financial stress, a churn risk factor |
| `Geography` | Categorical | Market region (France, Germany, Spain); Germany showed 2× higher churn rate |
| `Gender` | Categorical | Demographic segment; female customers churn at 25% vs 16% for male |
| `Age` | Numeric | Customer age; churn risk increases significantly above 50 |
| `Tenure` | Numeric | Years as a customer; does not strongly predict churn in a linear way |
| `Balance` | Numeric | Account balance; counter-intuitively, churned customers hold *higher* balances (€91k vs €73k) |
| `NumOfProducts` | Numeric | Number of products held; 2-product customers have the lowest churn (7.58%) |
| `HasCrCard` | Binary | Credit card holder flag; minimal predictive signal in isolation |
| `IsActiveMember` | Binary | Activity status; inactive customers churn at 26.85% vs 14.27% for active — a 1.9× gap |
| `EstimatedSalary` | Numeric | Income proxy; not a strong individual predictor |
| `Exited` | Binary | **Target variable** — 1 if customer churned, 0 if retained |
| `transaction_frequency` | Engineered | Monthly transaction count; low frequency signals disengagement |
| `avg_txn_value` | Engineered | Average transaction amount; declining value may signal shifting wallet share |
| `failed_transactions` | Engineered | Count of payment failures; high failure rate correlates with churn |
| `payment_failure_rate` | Engineered | Ratio of failed to total transactions; key risk signal |
| `monthly_txn_volume` | Engineered | Total monthly transaction volume in euros |
| `last_transaction_days` | Engineered | Days since last transaction; recency is a leading churn indicator |
| `Age_Bucket` | Engineered | Age group: 18-29, 30-44, 45+ |
| `Tenure_Bucket` | Engineered | Tenure group: 0-2, 3-5, 6-8, 9-10 years |
| `Risk_Segment` | Engineered | Three-tier classification: High Risk, Medium Risk, Low Risk |
| `Risk Score` | Engineered | Composite score 0–10 derived from activity, product count, payment failure rate, and balance profile |
---

## Project Workflow

```
Business Understanding (Define the retention problem and financial stakes)
        ↓
Excel Analysis (KPI creation, segmentation, risk scoring, executive dashboard)
        ↓
SQL Analysis (Database setup, churn rate verification, business queries)
        ↓
Python EDA — Notebook 1 (Distribution, geography, age, product, activity analysis)
        ↓
Python Cohort Analysis — Notebook 2 (Tenure cohorts, cross-segment heatmaps)
        ↓
Machine Learning — Notebook 3 (Logistic Regression + Random Forest, feature importance)
        ↓
Business Output (AT_RISK_CUSTOMERS list with Risk Score for CRM targeting)
        ↓
Recommendations (Segment-specific retention actions with estimated impact)
```

---

## Excel Analysis

Five sheets. Each with a specific business purpose.

# Sheet 1: Churn_Modelling (Enriched Dataset)
The base 10,000-row dataset augmented with 10 engineered features. This is the single source of truth for all downstream analysis. Key additions beyond the raw dataset include `payment_failure_rate` (failed transactions ÷ total transactions), `Risk_Segment` (High / Medium / Low), and `Risk Score` (0–10 composite).

# Sheet 2: ANALYSIS (Business KPIs)
The analytical core of the Excel workbook. Built using `COUNTIFS`, `SUMIFS`, and basic aggregation to produce:

- Overall churn rate: 20.37% (2,037 / 10,000)
- Geography breakdown: Germany 32.44% · France 16.15% · Spain 16.67%
- Gender breakdown: Female 25.07% · Male 16.46%
- Activity status: Inactive 26.85% · Active 14.27%
- Product count: 1 product 27.71% · 2 products 7.58% (lowest) · 3 products 82.71% · 4 products 100%
- Balance comparison: Churned customers hold €91,108 on average vs €72,745 for retained — a counter-intuitive finding that signals these are not low-value customers leaving out of neglect
- Revenue At Risk: €80,941,411**

The balance finding is strategically important: it means the highest-value customers are churning. A standard "protect the bottom" retention strategy would fail here.

# Sheet 3: PIVOT_TABLES (Segmentation)
Three pivot tables covering Age Bucket, Tenure Bucket, and Geography — giving a fast cross-sectional view of churn rates across dimensions. All three show that churn is roughly uniform across tenure but concentrated in Germany regardless of tenure cohort.

# Sheet 4: DASHBOARD (Executive Summary)
Four headline KPIs (Churn Rate, Churned Customers, Revenue At Risk, Highest Risk Market) followed by five insight bullets designed for a board update or leadership review:

- Germany churn rate is 32.44%, ~2× France and Spain
- Inactive customers churn 1.9× more than active customers
- Customers with 2 products show the lowest churn rate (7.58%)
- Churned customers hold higher average balances (€91k vs €73k)
- Revenue at risk exceeds €80.9M

# Sheet 5: AT_RISK_CUSTOMERS (Actionable Output)
The most operationally valuable output: a filtered list of high-risk customers with their full profile, Risk Segment classification, and Risk Score (6–10). This is what a CRM team, relationship manager, or retention campaign would actually use. It converts analysis into action.
---

## SQL Analysis

Database: `fintech_churn`  
Table: `fintech_churn_excel_analysis`

# Queries Built

Setup:
```sql
CREATE DATABASE fintech_churn;
USE fintech_churn;
```

Data validation:**
```sql
SELECT COUNT(*) FROM fintech_churn_excel_analysis;
SELECT * FROM fintech_churn_excel_analysis LIMIT 5;
```

Core business metric — overall churn rate:**
```sql
SELECT
    COUNT(*) AS total_customers,
    SUM(Exited) AS churned_customers,
    ROUND(SUM(Exited) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM fintech_churn_excel_analysis;
```
Result: 10,000 customers · 2,037 churned · 20.37% churn rate*

This query is the foundation for all downstream business reporting. It confirms the Python and Excel figures independently, which matters for data integrity in a real analytical environment.

SQL development roadmap (Implemented 13+ SQL queries covering churn analysis, customer segmentation, cohort analysis, RFM scoring, ROI estimation, and executive reporting.):
The SQL phase is being expanded to include churn segmentation by geography, age (using `CASE WHEN` bucketing), activity status, product count, and balance tier — as well as window functions for ranking, revenue at risk calculation, and the at-risk customer scoring query.

---

## Python Analysis

# Notebook 1: Exploratory Data Analysis (`notebook1_eda.ipynb`)

**Libraries:** `pandas`, `matplotlib`, `seaborn`

Setup and cleaning:**
- Loaded 10,000-row dataset, confirmed shape
- Dropped non-predictive ID columns: `RowNumber`, `CustomerId`, `Surname`
- No missing values in the base dataset

Key findings from EDA:

Churn distribution: 
20.37% churn rate — 2,037 customers. High enough to be a material business problem; not so high as to suggest data quality issues.

Geography analysis:
Germany stands apart. Churn rate by geography computed using `groupby` + `agg`:
- Germany: 32.44%
- France: 16.15%
- Spain: 16.67%

Germany accounts for roughly 25% of the customer base but a disproportionate share of churned customers. This is not random — it suggests a market-specific product fit, pricing, or competitive problem.

Age analysis:
Customers were bucketed into 18-30, 31-40, 41-50, 51-60, and 60+ using `pd.cut`. Churn rises significantly above age 50. The 51-60 cohort shows the highest concentration of exits. Older customers may be seeking relationship banking, which a digital-first fintech is less equipped to provide.

Product count analysis:
The non-linear relationship between products and churn is the most important finding in the entire project:
- 1 product: 27.71% churn
- 2 products: 7.58% churn ← inflection point
- 3 products: 82.71% churn
- 4 products: 100% churn

This U-shape suggests that 2-product customers are the core retention sweet spot. Customers with 3+ products may be over-sold, creating product fatigue or complexity-driven disengagement.

Activity analysis:
Inactive members churn at 26.85% — nearly double the 14.27% rate for active members. Engagement is the single most actionable lever visible in this dataset.

Correlation heatmap:
Built using `seaborn.heatmap` on the numeric feature matrix. Age shows the strongest positive correlation with churn. Balance shows a negative correlation (retained customers have lower balances on average — confirming the ANALYSIS sheet finding).

---

# Notebook 2: Cohort Analysis (`notebook2_cohort.ipynb`)

Libraries: `pandas`, `matplotlib`, `seaborn`

Tenure cohort analysis:**  
Customers grouped by tenure bucket (0-2, 3-5, 6-8, 9-10 years) to understand whether loyalty reduces churn risk. Findings: churn rate does not decline linearly with tenure. The 9-10 year cohort shows elevated churn (~21%), suggesting that even long-standing customers are not fully retained — possibly because they have the longest history of accumulated dissatisfaction or alternative discovery.

Geography × Age heatmap:
The strongest visualisation in the project. A cross-tabulation of geography by age bucket, using `seaborn.heatmap` to show churn rate at each intersection. The Germany × 45+ cell shows the highest concentration of churn risk in the entire dataset. This is a precise targeting signal: German customers over 45 should be the primary focus of any retention campaign.

Product × activity matrix:
Single-product, inactive customers represent the highest-risk combination in the dataset. This segment has both an engagement deficit and a product breadth deficit — two independent risk factors compounding each other.

**Executive summary (Notebook 2 outputs):**  
- Germany churn rate is 2× France and Spain and should be treated as a separate market problem
- Inactive customers churn at 1.9× the rate of active customers — re-engagement is the highest-ROI lever
- 2-product customers have the lowest churn — cross-sell from 1 to 2 products is the retention playbook
- Customers aged 45+ in Germany are the intersection of highest risk
- Tenure alone does not reduce churn — relationship quality matters more than relationship length

---

# Notebook 3: Churn Prediction (`notebook3_churn_model.ipynb`)

**Libraries:** `pandas`, `sklearn` (Logistic Regression, Random Forest, train_test_split, accuracy_score, roc_auc_score, confusion_matrix, LabelEncoder)

Data preparation:
- Categorical encoding: `Geography` and `Gender` encoded using `LabelEncoder`
- Train-test split: 80% train, 20% test (random_state=42)

Model 1: Logistic Regression
Baseline linear classifier. Suitable for understanding directional feature relationships. Serves as a performance benchmark for the Random Forest.

Model 2: Random Forest Classifier
Ensemble of decision trees with 100 estimators. Handles non-linear relationships in the data — important given the non-linear product-count × churn dynamic observed in EDA. Evaluated using accuracy and ROC-AUC score.

Feature importance:
Random Forest feature importance plotted using `matplotlib`. The analysis confirms what EDA suggested: `Age`, `IsActiveMember`, `Balance`, and `NumOfProducts` are the strongest predictors of churn. `CreditScore` and `HasCrCard` have minimal predictive power in isolation.

Output:  
High-churn probability customers identified and tagged for the AT_RISK_CUSTOMERS output list.

Planned additions: 
- XGBoost model with SHAP value interpretation for feature explainability
- `classification_report()` for precision, recall, and F1 by class
- ROC curve plotted visually for model comparison
- Threshold tuning (default 0.5 is suboptimal for churn; a lower threshold increases recall, reducing false negatives)

---

## Key Findings

| # | Finding | Severity | Business Implication |
|---|---|---|---|
| 1 | Germany churn rate is 32.44% — 2× France and Spain | 🔴 Critical | Germany requires a market-specific retention strategy, not a generic campaign |
| 2 | Churned customers hold €91k in average balance vs €73k for retained | 🔴 Critical | High-value customers are leaving — this is a premium segment problem, not a low-tier problem |
| 3 | Revenue at risk: €80.94M | 🔴 Critical | This is a P&L-level issue, not a CX issue — it should be escalated to CFO level |
| 4 | Inactive customers churn at 26.85% — 1.9× the active rate | 🔴 Critical | Re-engagement programs have a clear, quantifiable ROI target |
| 5 | 3-product customers churn at 82.71%; 4-product customers at 100% | 🟡 High | Over-selling destroys retention — stop bundling above 2 products without understanding why customers disengage |
| 6 | 2-product customers churn at only 7.58% | 🟡 High | The cross-sell from 1 to 2 products is the single most actionable retention move |
| 7 | Female customers churn at 25.07% vs 16.46% for male | 🟡 High | Gender-specific product or service gaps need investigation |
| 8 | Customers aged 51-60 show the highest churn rate | 🟡 Medium | Older customers may need relationship-banking touchpoints that digital fintechs often underinvest in |
| 9 | Tenure does not reduce churn linearly — 9-10 year customers still show 21% churn | 🟡 Medium | Loyalty is not automatic; relationship health must be actively maintained |
| 10 | Germany × Age 45+ is the highest-risk intersection | 🟡 Medium | Precise targeting opportunity: ~300 customers, ~€27M in estimated at-risk assets |

---

## Recommendations

| Recommendation | Expected Impact | Owner | Priority |
|---|---|---|---|
| Launch a Germany-specific retention program for customers aged 45+ | Reduce Germany churn from 32.44% to below 25% | Country Manager, Germany | Immediate |
| Build an inactivity detection trigger: flag customers with 0 transactions in 30 days and auto-assign to a CRM outreach sequence | Reduce inactive churn from 26.85% toward the 14-16% active baseline | Growth / CRM Team | Immediate |
| Audit the 3-product and 4-product customer experience — understand why over-served customers churn at 82-100% before running any upsell campaigns | Prevent further churn acceleration from bad cross-sell | Product Team | High |
| Design a "1 to 2 product" cross-sell campaign — the data shows 2-product customers churn at 7.58% vs 27.71% for 1-product customers | Shift single-product customers to the retention sweet spot | Product / Marketing | High |
| Use the AT_RISK_CUSTOMERS list (Risk Score ≥ 6) for direct outreach — assign relationship managers to the top 200 by balance | Protect the highest-value at-risk assets | Retention / RM Team | High |
| Investigate the gender churn gap (25% female vs 16% male) — run qualitative research or survey churned female customers | Identify product or UX gaps specific to female customers | Product / Research | Medium |
| Implement churn probability scoring in production using the Random Forest model, with weekly re-scoring | Automate at-risk identification without manual analysis | Data / Engineering | Medium |

---

## Dashboard (Tableau)

> Status: Coming Soon
---

## Repository Structure

```
fintech-churn-intelligence/
│
├── README.md
│
├── 01_Data/
│   └── Churn_Modelling.csv              ← Base dataset (10K rows, 12 columns)
│
├── 02_Excel/
│   └── Fintech_Churn_Intelligence.xlsx  ← 5-sheet workbook (Analysis, Pivots, Dashboard, At-Risk)
│
├── 03_SQL/
│   └── fintech_churn_queries.sql        ← Database setup and business queries
│
├── 04_Python/
│   ├── notebook1_eda.ipynb              ← EDA: distributions, geography, age, products, activity
│   ├── notebook2_cohort.ipynb           ← Cohort: tenure, geography×age heatmap, segment analysis
│   └── notebook3_churn_model.ipynb      ← ML: Logistic Regression + Random Forest + feature importance
│
├── 05_Outputs/
│   ├── at_risk_customers.csv            ← CRM-ready at-risk customer list with risk scores
│   └── charts/                          ← Exported visualisations from Python notebooks
│
└── 06_Dashboard/
    └── [Tableau — Coming Soon]
```

---

## Tech Stack

| Tool | Use Case |
|---|---|
| Excel | KPI calculation, feature engineering, risk scoring, executive dashboard |
| MySQL | Data validation, churn rate queries, business logic verification |
| Python (pandas) | Data manipulation, EDA, feature engineering |
| Python (matplotlib / seaborn) | Visualisation — distribution charts, heatmaps, bar charts |
| Python (scikit-learn) | Logistic Regression, Random Forest, model evaluation |
| Tableau | Executive dashboard and interactive segment explorer *(in progress)* |

---

## Key Skills Demonstrated

- Customer analytics and churn modelling
- Feature engineering on structured financial data
- Cohort analysis and segment-level retention analysis
- Predictive modelling (classification)
- Revenue impact quantification
- Executive communication and business storytelling
- End-to-end analytical workflow: raw data → insight → action
- CRM-ready output generation (AT_RISK_CUSTOMERS list)

---

## Business Impact Summary
- Identified €80.94M in assets at risk from a 20.37% annual churn rate
- Pinpointed Germany as a market requiring immediate intervention (32.44% churn vs 16% peers)
- Discovered that 2-product customers churn 3.7× less than single-product customers — a clear product strategy lever
- Found that churned customers hold 25% higher average balances than retained customers, inverting the assumption that churned customers are low-value
- Produced a **ranked at-risk customer list** with risk scores 0–10 for direct CRM and relationship manager activation
- Quantified the **inactivity churn premium** (1.9× higher churn for inactive members), providing a measurable ROI target for re-engagement investment
---

## Future Enhancements
- XGBoost model with SHAP interpretation** for explainable feature importance at customer level
- Real-time churn scoring pipeline using Python + scheduled SQL jobs
- A/B testing framework** to measure the lift from retention campaign interventions
- LTV-weighted risk scoring** — not all €80.94M is equal; weight risk scores by projected lifetime value
- Automated alerts** when a customer's activity score drops below a configurable threshold
- Tableau dashboard deployment** on Tableau Public with full interactive filtering
---

## License
MIT License — free to use, adapt, and reference with attribution.
---

*Project by Sumit Kumar Gupta · [https://www.linkedin.com/in/sumitgupta-analyst/) · [https://github.com/Sumit-kr-Gupta)
