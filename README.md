# Fintech Churn Intelligence

**End-to-end customer churn analysis, segmentation, and predictive risk scoring for a fintech retail banking business — built in SQL, Excel, and Python.**

---
# Table of Contents

- [1. Executive Summary](#1-executive-summary)
- [2. Business Problem](#2-business-problem)
- [3. Business Context](#3-business-context)
- [4. Objectives](#4-objectives)
- [5. Business Questions](#5-business-questions)
- [6. Dataset Overview](#6-dataset-overview)
- [7. Data Architecture](#7-data-architecture)
- [8. Technology Stack](#8-technology-stack)
- [9. SQL Analysis](#9-sql-analysis)
- [10. Python Analysis](#10-python-analysis)
- [11. Excel Dashboard](#11-excel-dashboard)
- [12. Tableau Dashboard](#12-tableau-dashboard)
- [13. KPI Framework](#13-kpi-framework)
- [14. Analytical Methodology](#14-analytical-methodology)
- [15. Business Insights](#15-business-insights)
- [16. Executive Recommendations](#16-executive-recommendations)
- [17. Revenue Impact](#17-revenue-impact)
- [18. Business Value](#18-business-value)
- [19. Repository Structure](#19-repository--folder-structure)
- [20. Key Skills Demonstrated](#20-key-skills-demonstrated)
- [21. Challenges & Assumptions](#21-challenges--assumptions)
- [22. Future Enhancements](#22-future-enhancements)
- [23. Screenshots](#23-screenshots)
- [24. How to Run This Project](#24-how-to-run-this-project)
- [25. Conclusion](#25-conclusion)

## Executive Summary

10,000 customers, 20.37% churn rate, and a business that doesn't yet know which customers are about to leave or why. This project answers both questions using a three-layer analytics stack:

- **SQL** establishes the descriptive and diagnostic baseline — churn rates by segment, cross-tabulated risk cohorts, and revenue-at-risk.
- **Excel** turns that baseline into a stakeholder-facing dashboard and pivot-table view for non-technical reviewers.
- **Python** goes further than descriptive analysis: it builds a tuned Random Forest model (ROC-AUC 0.864) that predicts individual churn probability, validates that score with decile lift analysis (top decile churns at 4.03x the base rate), and explains every prediction with SHAP.

The headline finding: churn here is not driven by any single variable, but by **segment intersections**. Germany customers alone churn at 32.4%; customers aged 51-60 alone churn at 56.2%; combine Germany + age 51-60 + inactive, and churn hits ~88% — a cohort small enough (~130 customers) to retain with direct, individual outreach rather than a broad campaign.

---

## Business Problem

The business has no systematic way to answer three questions a retention team needs answered before it can act:

1. Which customers are leaving, and is churn concentrated in specific segments or spread evenly across the base?
2. Which of those segments are large enough, and clearly-defined enough, to justify a targeted retention campaign?
3. Which *individual* customers are at risk right now, ranked by probability, so outreach can be prioritized by expected impact rather than by which segment they happen to fall into?

A churn rate on its own doesn't answer any of these. This project builds the layers of analysis needed to move from "20% of customers churn" to "these 403 specific customers, in this order, are worth calling this month."

---

## Business Context

The dataset represents a retail banking / fintech customer base across three European markets (France, Germany, Spain), with standard account attributes (credit score, balance, product holdings, activity status) and a binary churn flag. Retaining an existing customer is materially cheaper than acquiring a new one, which is what makes even a moderately accurate, well-explained risk score commercially useful — it converts a reactive "customer already left" problem into a proactive, ranked outreach list.

---

## Objectives

- Quantify overall and segment-level churn to establish a defensible baseline.
- Identify which customer segments carry disproportionate churn risk, and validate that risk isn't just single-variable noise.
- Build a predictive model that scores individual customers by churn probability, correctly handling class imbalance (~80/20 retained/churned).
- Explain the model's predictions in business language (SHAP), not just report an accuracy number.
- Translate findings into a prioritized, actionable retention list and a set of executive recommendations.

---

## Business Questions

1. What is the overall churn rate, and how does it vary by geography, gender, age, activity status, and product count?
2. Do individually high-risk segments compound when combined, and by how much?
3. Can churn be predicted at the individual customer level with enough accuracy to be useful for targeting?
4. Which features actually drive the model's predictions, and do they match the patterns found in EDA?
5. What is a realistic, prioritized list of retention actions, given cohort sizes and campaign cost?

---

## Dataset Overview

**Core dataset — `Churn_Modelling.csv`** (used across SQL, Excel, and all three Python notebooks): 10,000 customers, 14 attributes — `CustomerId`, `CreditScore`, `Geography`, `Gender`, `Age`, `Tenure`, `Balance`, `NumOfProducts`, `HasCrCard`, `IsActiveMember`, `EstimatedSalary`, `Exited` (target).

**Extended engagement layer (SQL / Excel only):** the workbook adds transaction-level fields — `transaction_frequency`, `avg_txn_value`, `failed_transactions`, `last_transaction_days`, `payment_failure_rate`, `monthly_txn_volume` — plus derived buckets (`Age_Bucket`, `Tenure_Bucket`, `Risk_Segment`). These are **illustrative behavioral data**, layered on top of the core dataset to support the SQL revenue-at-risk and RFM-style segmentation work. They are a separate analytical exercise from the machine learning model below and are labeled as such throughout — see [Two Analytical Layers](#two-analytical-layers-important) for why they're kept apart rather than merged into one score.

No missing values or duplicate rows in the core dataset (verified in `01_eda.ipynb`).

---

## Data Architecture

```
Raw Data (Churn_Modelling.csv, 10,000 rows)
        │
        ├── SQL (MySQL) ──────────► Descriptive, diagnostic & revenue analysis
        │                            (engagement layer: transaction fields, Risk_Segment)
        │
        ├── Excel (openpyxl-built) ─► Pivot tables + executive dashboard
        │                            (same engagement layer, stakeholder-facing view)
        │
        └── Python (pandas/sklearn) ► EDA → Cohort validation → ML risk model
                                       (core dataset only — no engagement layer)
```

---

## Technology Stack

| Layer | Tools |
|---|---|
| Database & querying | MySQL |
| Spreadsheet analysis | Excel (PivotTables, `COUNTIFS`/`SUMIFS`/`AVERAGEIF`, executive dashboard) |
| Data analysis | Python — `pandas`, `numpy` |
| Visualization | `matplotlib`, `seaborn` |
| Machine learning | `scikit-learn` (Logistic Regression, Random Forest, `GridSearchCV`, `StratifiedKFold`) |
| Model explainability | `SHAP` |
| Dashboard (in progress) | Tableau |

---

## SQL Analysis

`fintech_churn_querie.sql` is organized into three tiers, each answering a different class of business question:

- **Section 1 — Descriptive & Exploratory:** overall churn rate, and single-dimension breakdowns by geography, gender, activity status, product count, and age band.
- **Section 2 — Diagnostic & Segmentation:** an actionable at-risk customer list (still-active, single-product, inactive customers ranked by balance), tenure-based retention cohorts, and a geography × gender cross-tab.
- **Section 3 — Strategic & Decision-Support:** RFM-style customer segmentation (`NTILE` quartiles on transaction frequency and value), a revenue-at-risk and retention-campaign ROI calculator (built with a `WITH` CTE), and a UNION-based executive KPI summary.

The ROI calculator assumes a 20% revenue-recovery rate and a $15-per-customer campaign cost — stated here explicitly as **illustrative assumptions**, not sourced figures, since no benchmark is cited in the query itself.

---

## Python Analysis

Three notebooks, each building on the last:

**`01_eda.ipynb` — Exploratory Data Analysis.** Establishes the churn baseline (20.37%) and single-variable patterns: Germany churns at ~2x France/Spain, ages 51-60 are the highest-risk band (not the youngest or oldest customers), and the relationship between product count and churn is **non-monotonic** — 2-product holders churn least (7.6%) but 3- and 4-product holders churn at 82.7% and 100%, a small, extreme segment worth root-cause investigation rather than a blanket cross-sell push.

**`02_cohort.ipynb` — Segmentation & Cohort Validation.** Moves past single-variable EDA to cross-tabulated cohorts. Confirms that high-risk segments compound: Germany + age 51-60 churns at 69.5% (vs. 32.4% and 56.2% individually), and adding an inactivity filter pushes the compound cohort to ~88% churn — a 4.3x lift over the base rate, validated with a lift-ratio check rather than reported as a raw percentage.

**`03_churn_model.ipynb` — Prediction & Risk Scoring.** Builds and tunes a churn prediction model:
- One-hot encodes `Geography` (rather than label-encoding it, which would falsely imply an ordinal relationship between France/Germany/Spain).
- Compares Logistic Regression and Random Forest, with and without `class_weight="balanced"`, to correct for the ~80/20 class imbalance.
- Tunes the Random Forest via 5-fold `StratifiedKFold` `GridSearchCV`, optimizing ROC-AUC (threshold-independent, unlike accuracy under imbalance).
- Scans decision thresholds instead of defaulting to 0.50, since a missed churner is costlier to the business than a wasted retention offer.
- Validates the resulting risk score with decile lift analysis and explains predictions with SHAP, cross-checked against native Gini feature importance.

**Final model result:** Tuned Random Forest (`n_estimators=200`, `max_depth=None`, `min_samples_leaf=10`, `class_weight="balanced"`) — **ROC-AUC 0.8636** on the held-out test set (5-fold CV: 0.8594). At the F1-optimal threshold (0.55): precision 0.58, recall 0.69 on the churn class. Top predicted-risk decile churns at **4.03x** the base rate, confirming the score meaningfully separates high- and low-risk customers.

---

## Excel Dashboard

A five-sheet workbook: raw data, a formula-driven `ANALYSIS` sheet (churn by geography/gender/activity/products/balance), `PIVOT_TABLES` (age bucket, tenure bucket, geography), an `AT_RISK_CUSTOMERS` extract for outreach, and a one-page `DASHBOARD` summarizing the four headline KPIs (churn rate, churned customers, revenue at risk, highest-risk market) with the five most important findings underneath. Built for a non-technical stakeholder to read in under a minute.

---

## Tableau Dashboard

**Status: In Progress.** An interactive version of the Excel dashboard — with drill-down by geography, age band, and risk tier — is planned as the next deliverable.

---

## Customer KPI Framework

| KPI | Definition | Result |
|---|---|---|
| Churn Rate | Exited customers ÷ total customers | 20.37% |
| Revenue at Risk | Sum of monthly transaction volume for High Risk-segment customers | €80.94M (illustrative — engagement layer) |
| Model ROC-AUC | Area under the ROC curve, held-out test set | 0.8636 |
| Top-Decile Lift | Churn rate of top predicted-risk decile ÷ base churn rate | 4.03x |
| Cohort Lift (Germany + 51-60 + Inactive) | Cohort churn rate ÷ base churn rate | ~4.3x |

---

## Analytical Methodology

1. **Descriptive** (SQL, Excel) — establish the baseline and single-dimension breakdowns.
2. **Diagnostic** (SQL, Python cohort notebook) — cross-tabulate to find compounding risk, and validate every finding with a lift ratio rather than a raw percentage.
3. **Predictive** (Python model notebook) — build, tune, and validate a model that scores individual customers, with explicit correction for class imbalance and explicit threshold selection tied to business cost.
4. **Explanatory** (SHAP) — attribute every prediction to specific features, so risk scores are defensible to a stakeholder, not a black box.

---

## Customer Segmentation Framework

- **Single-variable segments:** geography, gender, age band, activity status, product count.
- **Compound cohorts:** two- and three-way intersections of the above (e.g., Germany × age 51-60 × inactive), which the EDA-only view understates by more than 2x.
- **Model-based risk tiers:** Low / Medium / High, built from predicted churn probability (thresholds at 0.30 and 0.60), validated against actual outcomes.

---

## Churn Risk Framework

Two Risk Score tracks exist in this project and are intentionally kept separate — see [Two Analytical Layers](#two-analytical-layers-important):

- **Excel/SQL `Risk_Segment`** — a rule-based High/Medium/Low tag derived from the illustrative engagement-layer fields (transaction frequency, failed transactions, payment failure rate), used for the SQL revenue-at-risk calculation.
- **Python model `Risk_Tier`** — a statistically validated tier derived from a tuned, cross-validated Random Forest's predicted probability, back-tested against actual churn outcomes via decile lift. **This is the risk score this project would recommend for real targeting decisions**, because it's the only one with out-of-sample validation behind it.

---

## Two Analytical Layers (Important)

This project deliberately runs two parallel analytical tracks rather than forcing them into one number:

1. **SQL + Excel** work from the core dataset *plus* an illustrative engagement layer (transaction frequency, failure rates, monthly volume) to demonstrate segmentation, RFM logic, and revenue-impact reasoning in a business-intelligence context.
2. **Python** works from the core, verified dataset only, and builds the actual validated predictive model.

They are not reconciled into a single score because the engagement-layer fields in (1) are illustrative rather than sourced, and merging them into the model in (2) would make the model's real, validated 0.864 ROC-AUC harder to defend. Kept apart, each track is honest about what it is: SQL/Excel demonstrate BI and revenue-framing skills on illustrative data; Python demonstrates a real, tested, explainable predictive model on verified data. In a production setting, the next step would be sourcing genuine transaction data and validating whether it improves the model — not assumed a priori.

---

## Business Insights

1. **Germany is a standalone retention problem.** 32.4% churn — roughly double France (16.2%) and Spain (16.7%) — on a comparable customer base, pointing to a market-specific issue (pricing, competition, service quality) rather than a company-wide one.
2. **Age 51-60 is the highest-risk band**, not the youngest or oldest customers — 56.2% churn, contradicting a naive "younger customers churn more" assumption.
3. **Product count is not "more is better."** 2-product holders are the *stickiest* segment (7.6% churn); 3- and 4-product holders churn at 83-100%, a small (266-customer) but severe segment likely tied to a specific bundle or onboarding cohort.
4. **Segments compound.** Germany + age 51-60 + inactive customers churn at ~88% — a 4.3x lift over baseline, concentrated in just ~130 customers, making direct 1:1 outreach economically viable.
5. **The model confirms EDA, quantitatively.** Age, product count, activity status, and Germany are the top SHAP drivers — the same variables EDA flagged, now ranked and quantified rather than eyeballed.

---

## Executive Recommendations

1. **Prioritize the model's High risk tier first** (403 customers in the test set, 63.3% actual churn rate) — highest expected return per outreach dollar.
2. **Run a targeted, individual retention effort for the Germany + 51-60 + inactive cohort** (~130 customers, ~88% churn) before a broad geography-wide campaign — smaller, higher-lift, and cheaper to execute well.
3. **Investigate the 3-4 product segment as a root-cause problem, not a cross-sell opportunity** — 266 customers at 83-100% churn is a signal something specific broke (a bundle, a pricing tier, an onboarding flow), not evidence that more products causes churn.
4. **Automate re-engagement for inactive members** — the largest, most scalable lever (26.9% vs. 14.3% churn), addressable without 1:1 outreach.
5. **Re-score monthly and monitor decile lift** to catch model drift before it erodes targeting accuracy.

---

## Business Impact & Value

- Converts an undifferentiated 20% churn rate into a ranked, 403-customer priority list with a validated 63.3% actual-churn hit rate — a meaningfully more efficient use of retention budget than blanket campaigns.
- Identifies a ~130-customer cohort at 88% churn risk, small enough for high-touch outreach and large enough to matter.
- Flags a 266-customer, 83-100%-churn product segment as a product/pricing investigation, not a marketing problem — the kind of finding that changes what a business builds, not just who it emails.

---

## Repository & Folder Structure

```
fintech-churn-intelligence/
├── README.md
├── 01_data/
│   └── Churn_Modelling.csv
├── 02_sql/
│   └── fintech_churn_queries.sql
├── 03_excel/
│   └── Fintech_Churn_Intelligence_Dashboard.xlsx
├── 04_python/
│   ├── 01_eda.ipynb
│   ├── 02_cohort.ipynb
│   └── 03_churn_model.ipynb
├── 05_dashboard/
│   └── (Tableau workbook — in progress)
├── screenshots/
│   └── dashboard_preview.png
└── docs/
    ├── Executive_Summary.md
    ├── Business_Problem.md
    ├── Business_Requirements.md
    ├── Data_Dictionary.md
    ├── Analysis_Methodology.md
    ├── Customer_KPI_Definitions.md
    ├── Customer_Segmentation.md
    ├── Churn_Risk_Framework.md
    ├── Business_Insights.md
    ├── Executive_Recommendations.md
    ├── Technical_Documentation.md
    └── Presentation_Guide.md
```

---

## Key Skills Demonstrated

SQL (CTEs, window functions, multi-tier query design) · Excel (formula-driven dashboards, PivotTables) · Python (pandas, EDA-to-model workflow) · Statistical validation (lift analysis, cross-validation, decile analysis) · Class-imbalance handling and threshold optimization · Model explainability (SHAP) · Business translation of technical findings into prioritized, cost-aware recommendations.

---

## Challenges & Assumptions

- The SQL/Excel engagement-layer fields (transaction frequency, failure rates) are illustrative, not sourced from a real payments system — stated explicitly rather than presented as verified data.
- The ROI calculator's 20% recovery rate and $15 campaign cost are assumptions for illustration, not benchmarked figures.
- Model results are based on a single train/test split with cross-validated tuning; a production deployment would need periodic re-validation against fresh outcome data (churn ground truth naturally lags).

---

## Future Enhancements

- Replace the illustrative engagement layer with real transaction data, and test whether it improves the ML model's ROC-AUC beyond 0.864.
- Complete the Tableau dashboard with drill-down by risk tier and cohort.
- Add a monthly re-scoring pipeline and a model-drift monitoring view (decile lift over time).
- Test additional model families (XGBoost, LightGBM) against the current Random Forest baseline.

---

## Screenshots

*(Dashboard and notebook output screenshots to be added to `/screenshots`.)*

---

## How to Run This Project

**SQL:** Import `Churn_Modelling.csv` into MySQL, then run `fintech_churn_queries.sql` section by section (Section 0 first, to create the database).

**Excel:** Open `Fintech_Churn_Intelligence_Dashboard.xlsx` — all figures are formula-driven and recalculate automatically if the underlying data changes.

**Python:**
```bash
pip install pandas numpy matplotlib seaborn scikit-learn shap
jupyter notebook 04_python/01_eda.ipynb
```
Run notebooks in order (`01_eda` → `02_cohort` → `03_churn_model`); each depends on the same source CSV loaded independently at the top of each notebook.

---

## Conclusion

This project moves from a single churn-rate number to a validated, individually-scored, explainable retention system — the difference between "20% of customers churn" and "these 403 customers, in this order, are worth calling this month, and here's why." The SQL and Excel layers demonstrate business-intelligence and stakeholder-communication skills on an illustrative engagement dataset; the Python layer demonstrates a real, cross-validated, explainable predictive model on verified data. Kept honest about which is which, rather than blended into one inflated claim.

---


