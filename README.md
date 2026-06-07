# HR-Employee-Attrition-Analysis


# 👥 HR Employee Attrition Analysis

**Tools:** SQL (MySQL) · Python · Power BI  
**Domain:** Human Resources Analytics  
**Dataset:** 1,470 employees · 29 attributes  
**Author:** Pruthviraj Kadam  
**GitHub:** [Pruthvirajsk09](https://github.com/Pruthvirajsk09)

---

## 📌 Problem Statement

A company is experiencing high employee turnover increasing hiring and training costs. The HR team needs to understand **why employees are leaving**, which departments are most affected, and **identify at-risk employees before they resign**.

> *"Replacing one employee costs 6–9 months of their salary. With 471 employees leaving, the financial impact runs into crores."*

---

## 🎯 Business Objectives

| # | Business Question | Tool Used |
|---|---|---|
| 1 | What is our overall attrition rate? | SQL + Power BI KPI Card |
| 2 | Which department loses the most people? | SQL GROUP BY + Bar Chart |
| 3 | Are low-paid employees leaving more? | SQL CASE WHEN + Power BI |
| 4 | Does overtime cause attrition? | SQL + Python Chart |
| 5 | Which employees are flight risks right now? | SQL CTE Risk Model |

---

## 📊 Key Findings

| Insight | Finding |
|---|---|
| Overall Attrition Rate | **32%** — 471 out of 1,470 employees left |
| Top Risk Department | Human Resources has highest attrition rate |
| Overtime Impact | Overtime employees leave **1.5× more** than non-overtime |
| Highest Risk Tenure | Employees in **first 2 years** — 36% attrition rate |
| Satisfaction Impact | Low satisfaction employees leave **45% more** |
| Critical Risk Group | 244 employees flagged as critical risk |
| Income Gap | Attrited employees earned **$195/month less** on average |

---

## 🗂️ Project Structure

```
hr-attrition-analysis/
│
├── data/
│   └── hr_employee_data.csv        ← Main dataset (1,470 rows, 29 columns)
│
├── sql/
│   └── hr_attrition_analysis.sql   ← 15+ SQL queries across 10 sections
│
├── hr_attrition_analysis.py        ← Python EDA + 6 visualizations
│
├── docs/
│   ├── dashboard_overview.png      ← Python chart — Executive overview
│   ├── dashboard_deep_dive.png     ← Python chart — Demographics & risk
│   ├── powerbi_page1.png           ← Power BI Page 1 screenshot
│   ├── powerbi_page2.png           ← Power BI Page 2 screenshot
│   ├── powerbi_page3.png           ← Power BI Page 3 screenshot
│   └── hr_attrition_dashboard.pdf  ← Full Power BI dashboard export
│
└── README.md
```

---

## 🛠️ Tool 1 — SQL (MySQL)

**What I did:** Wrote 15+ queries across 10 analysis sections to answer every business question.

**Sections covered:**
- Overview KPIs — total employees, attrition rate, avg salary
- Department Analysis — attrition rate by dept and job role
- Salary Band Analysis — CASE WHEN binning, income gap
- Overtime Impact — comparison query
- Tenure Buckets — risk window analysis
- Satisfaction Scores — all 4 satisfaction dimensions
- CTE Risk Model — multi-factor scoring with CASE WHEN weights
- Window Functions — RANK, cumulative attrition

**Most important query — Risk Scoring Model using CTE:**
```sql
WITH risk_scoring AS (
    SELECT
        EmployeeID, Department, JobRole, MonthlyIncome, Attrition,
        (
            CASE WHEN OverTime = 'Yes'            THEN 2 ELSE 0 END +
            CASE WHEN JobSatisfaction <= 2         THEN 2 ELSE 0 END +
            CASE WHEN WorkLifeBalance <= 2         THEN 2 ELSE 0 END +
            CASE WHEN YearsAtCompany <= 2          THEN 1 ELSE 0 END +
            CASE WHEN MonthlyIncome < 3000         THEN 1 ELSE 0 END +
            CASE WHEN YearsSinceLastPromotion >= 3 THEN 1 ELSE 0 END +
            CASE WHEN NumCompaniesWorked > 5       THEN 1 ELSE 0 END
        ) AS risk_score
    FROM employees
)
SELECT *,
    CASE
        WHEN risk_score >= 6 THEN 'Critical Risk'
        WHEN risk_score >= 4 THEN 'High Risk'
        WHEN risk_score >= 2 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_category
FROM risk_scoring
ORDER BY risk_score DESC;
```

**Why CTE here?** Because we first needed to calculate the risk score per employee, then categorize based on that score. CTE lets us use the result of one query inside another — not possible with a simple subquery cleanly.

---

## 🐍 Tool 2 — Python

**What I did:** Data loading, cleaning, exploratory analysis, and 6 visualizations.

**Libraries:** Pandas, NumPy, Matplotlib, Seaborn

**Analysis performed:**
```python
import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('data/hr_employee_data.csv')

# Data profiling
print(df.shape)           # 1470 rows, 29 columns
print(df.isnull().sum())  # 0 missing values — clean dataset

# Key finding
left   = df[df['Attrition'] == 'Yes']
stayed = df[df['Attrition'] == 'No']
print(f"Avg salary left  : ${left['MonthlyIncome'].mean():,.0f}")
print(f"Avg salary stayed: ${stayed['MonthlyIncome'].mean():,.0f}")

# Groupby analysis
df.groupby('Department')['Attrition'].value_counts()
df.groupby('OverTime')['Attrition'].value_counts()
```

**6 Charts generated:**
1. Overall attrition donut chart
2. Attrition rate by department
3. Salary band vs attrition rate
4. Overtime impact comparison
5. Satisfaction scores heatmap
6. Risk model validation chart

### Python Dashboard Preview
![Executive Overview](docs/dashboard_overview.png)
![Deep Dive Analysis](docs/dashboard_deep_dive.png)

---

## 📊 Tool 3 — Power BI

**What I built:** 3-page interactive dashboard with DAX measures and slicers.

**DAX Measures written:**
```dax
-- Attrition Rate
Attrition Rate % =
DIVIDE([Total Attrition], [Total Employees], 0) * 100

-- Why DIVIDE and not /? 
-- DIVIDE handles division by zero automatically
-- Prevents dashboard errors when filters reduce count to 0

-- Critical Risk Count
Critical Risk Employees =
CALCULATE(
    COUNTROWS(employees),
    employees[RiskScore] >= 6
)
```

**Page 1 — Executive Overview**
- 4 KPI Cards: Total Employees, Attrition Count, Attrition Rate %, Avg Salary
- Donut chart: Attrition breakdown
- Bar chart: Attrition by department
- Slicers: Department, Gender, OverTime, Marital Status

**Page 2 — Risk Factor Analysis**
- Overtime vs attrition column chart
- Job satisfaction vs attrition
- Tenure band vs attrition
- Department × Salary Band heatmap matrix with conditional formatting

**Page 3 — Employee Risk Tracker**
- Employee-level table with conditional formatting
- Risk category distribution chart
- Critical risk KPI card
- Business recommendation text box

### Power BI Dashboard Preview
![Power BI Page 1](docs/powerbi_page1.png)
![Power BI Page 2](docs/powerbi_page2.png)
![Power BI Page 3](docs/powerbi_page3.png)

---

## 💡 Business Recommendations

1. **Address Overtime Immediately** — Overtime employees are 1.5× more likely to leave. Implement overtime monitoring and workload caps.

2. **Early Tenure Intervention** — 36% of employees in first 2 years leave. Build a structured 90-day onboarding and 1-year check-in program.

3. **Proactive Risk Monitoring** — 244 critical-risk employees identified. HR should conduct quarterly stay interviews with this group.

4. **Compensation Review** — Employees earning below $3,000/month have significantly higher attrition. A salary band review is recommended.

---

## 🚀 How to Run

```bash
# 1. Clone the repo
git clone https://github.com/Pruthvirajsk09/hr-attrition-analysis

# 2. Install Python dependencies
pip install pandas numpy matplotlib seaborn

# 3. Run Python EDA
python hr_attrition_analysis.py

# 4. Load data into MySQL
# Open MySQL Workbench
# Run sql/hr_attrition_analysis.sql

# 5. Load data into Power BI
# Open Power BI Desktop
# Get Data → CSV → hr_employee_data.csv
```

---

## 📬 Connect

**Pruthviraj Kadam**  
📧 pruthvirajkadam009@gmail.com  
🔗 [LinkedIn][https://linkedin.com/in/pruthvirajkadam] | [GitHub](https://github.com/Pruthvirajsk09)
