-- ============================================================
-- HR EMPLOYEE ATTRITION ANALYSIS
-- Author: Pruthviraj Kadam
-- Tool: SQL (compatible with MySQL / PostgreSQL / SQLite)
-- Dataset: 1,470 employee records | 29 columns
-- ============================================================

-- ============================================================
-- SECTION 1: DATABASE SETUP
-- ============================================================

CREATE TABLE hr_employees (
    EmployeeID          INT PRIMARY KEY,
    Age                 INT,
    Gender              VARCHAR(10),
    MaritalStatus       VARCHAR(15),
    Department          VARCHAR(50),
    JobRole             VARCHAR(50),
    EducationField      VARCHAR(50),
    Education           INT,
    BusinessTravel      VARCHAR(25),
    DistanceFromHome    INT,
    MonthlyIncome       INT,
    PercentSalaryHike   INT,
    StockOptionLevel    INT,
    OverTime            VARCHAR(5),
    JobSatisfaction     INT,
    EnvironmentSatisfaction INT,
    RelationshipSatisfaction INT,
    WorkLifeBalance     INT,
    PerformanceRating   INT,
    JobInvolvement      INT,
    JobLevel            INT,
    NumCompaniesWorked  INT,
    TotalWorkingYears   INT,
    TrainingTimesLastYear INT,
    YearsAtCompany      INT,
    YearsInCurrentRole  INT,
    YearsSinceLastPromotion INT,
    YearsWithCurrManager INT,
    Attrition           VARCHAR(5)
);


-- ============================================================
-- SECTION 2: OVERVIEW & KPIs
-- ============================================================

-- 2.1 Overall attrition rate
SELECT
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS total_attrition,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS attrition_rate_pct
FROM hr_employees;

-- 2.2 Average employee profile
SELECT
    ROUND(AVG(Age), 1)               AS avg_age,
    ROUND(AVG(MonthlyIncome), 0)     AS avg_monthly_income,
    ROUND(AVG(YearsAtCompany), 1)    AS avg_tenure_years,
    ROUND(AVG(TotalWorkingYears), 1) AS avg_total_exp_years,
    ROUND(AVG(JobSatisfaction), 2)   AS avg_job_satisfaction,
    ROUND(AVG(WorkLifeBalance), 2)   AS avg_work_life_balance
FROM hr_employees;


-- ============================================================
-- SECTION 3: ATTRITION BY DEPARTMENT & JOB ROLE
-- ============================================================

-- 3.1 Attrition by Department
SELECT
    Department,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrited,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS attrition_rate_pct
FROM hr_employees
GROUP BY Department
ORDER BY attrition_rate_pct DESC;

-- 3.2 Attrition by Job Role
SELECT
    JobRole,
    Department,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrited,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome), 0) AS avg_income
FROM hr_employees
GROUP BY JobRole, Department
ORDER BY attrition_rate_pct DESC;


-- ============================================================
-- SECTION 4: SALARY & INCOME ANALYSIS
-- ============================================================

-- 4.1 Attrition by salary band
SELECT
    CASE
        WHEN MonthlyIncome < 3000  THEN 'Low (< $3K)'
        WHEN MonthlyIncome < 7000  THEN 'Mid ($3K–$7K)'
        WHEN MonthlyIncome < 12000 THEN 'High ($7K–$12K)'
        ELSE 'Very High (> $12K)'
    END AS salary_band,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrited,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS attrition_rate_pct
FROM hr_employees
GROUP BY salary_band
ORDER BY attrition_rate_pct DESC;

-- 4.2 Average income: Active vs Attrited employees
SELECT
    Attrition,
    ROUND(AVG(MonthlyIncome), 0)   AS avg_monthly_income,
    ROUND(AVG(PercentSalaryHike), 1) AS avg_salary_hike_pct,
    COUNT(*) AS employee_count
FROM hr_employees
GROUP BY Attrition;

-- 4.3 Income gap by department between attrited and retained
SELECT
    Department,
    ROUND(AVG(CASE WHEN Attrition = 'No'  THEN MonthlyIncome END), 0) AS avg_income_retained,
    ROUND(AVG(CASE WHEN Attrition = 'Yes' THEN MonthlyIncome END), 0) AS avg_income_attrited,
    ROUND(
        AVG(CASE WHEN Attrition = 'No'  THEN MonthlyIncome END) -
        AVG(CASE WHEN Attrition = 'Yes' THEN MonthlyIncome END), 0
    ) AS income_gap
FROM hr_employees
GROUP BY Department
ORDER BY income_gap DESC;


-- ============================================================
-- SECTION 5: OVERTIME & WORK-LIFE BALANCE
-- ============================================================

-- 5.1 Overtime impact on attrition
SELECT
    OverTime,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrited,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS attrition_rate_pct
FROM hr_employees
GROUP BY OverTime;

-- 5.2 Work-life balance vs attrition
SELECT
    WorkLifeBalance,
    CASE WorkLifeBalance
        WHEN 1 THEN 'Bad'
        WHEN 2 THEN 'Good'
        WHEN 3 THEN 'Better'
        WHEN 4 THEN 'Best'
    END AS wlb_label,
    COUNT(*) AS total,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrited,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS attrition_rate_pct
FROM hr_employees
GROUP BY WorkLifeBalance
ORDER BY WorkLifeBalance;

-- 5.3 Combined: Overtime + Work-Life Balance
SELECT
    OverTime,
    WorkLifeBalance,
    COUNT(*) AS total,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS attrition_rate_pct
FROM hr_employees
GROUP BY OverTime, WorkLifeBalance
ORDER BY attrition_rate_pct DESC;


-- ============================================================
-- SECTION 6: TENURE & EXPERIENCE ANALYSIS
-- ============================================================

-- 6.1 Attrition by tenure band
SELECT
    CASE
        WHEN YearsAtCompany <= 2  THEN '0-2 Years (New)'
        WHEN YearsAtCompany <= 5  THEN '3-5 Years'
        WHEN YearsAtCompany <= 10 THEN '6-10 Years'
        ELSE '10+ Years (Senior)'
    END AS tenure_band,
    COUNT(*) AS total,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrited,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS attrition_rate_pct
FROM hr_employees
GROUP BY tenure_band
ORDER BY attrition_rate_pct DESC;

-- 6.2 Employees with no promotion in 3+ years
SELECT
    Department,
    COUNT(*) AS stagnant_employees,
    ROUND(AVG(MonthlyIncome), 0) AS avg_income,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrited,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS attrition_rate_pct
FROM hr_employees
WHERE YearsSinceLastPromotion >= 3
GROUP BY Department
ORDER BY attrition_rate_pct DESC;


-- ============================================================
-- SECTION 7: AGE & DEMOGRAPHICS
-- ============================================================

-- 7.1 Attrition by age group
SELECT
    CASE
        WHEN Age < 25 THEN 'Under 25'
        WHEN Age < 35 THEN '25-34'
        WHEN Age < 45 THEN '35-44'
        ELSE '45+'
    END AS age_group,
    COUNT(*) AS total,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrited,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS attrition_rate_pct
FROM hr_employees
GROUP BY age_group
ORDER BY attrition_rate_pct DESC;

-- 7.2 Attrition by marital status
SELECT
    MaritalStatus,
    COUNT(*) AS total,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrited,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome), 0) AS avg_income
FROM hr_employees
GROUP BY MaritalStatus
ORDER BY attrition_rate_pct DESC;

-- 7.3 Gender-wise attrition
SELECT
    Gender,
    COUNT(*) AS total,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrited,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS attrition_rate_pct
FROM hr_employees
GROUP BY Gender;


-- ============================================================
-- SECTION 8: SATISFACTION SCORES
-- ============================================================

-- 8.1 Job satisfaction vs attrition
SELECT
    JobSatisfaction,
    CASE JobSatisfaction
        WHEN 1 THEN 'Low'
        WHEN 2 THEN 'Medium'
        WHEN 3 THEN 'High'
        WHEN 4 THEN 'Very High'
    END AS satisfaction_label,
    COUNT(*) AS total,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrited,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS attrition_rate_pct
FROM hr_employees
GROUP BY JobSatisfaction
ORDER BY JobSatisfaction;

-- 8.2 Multi-factor satisfaction score (composite)
SELECT
    EmployeeID,
    Department,
    JobRole,
    Attrition,
    MonthlyIncome,
    ROUND((JobSatisfaction + EnvironmentSatisfaction + 
           RelationshipSatisfaction + WorkLifeBalance) / 4.0, 2) AS composite_satisfaction_score
FROM hr_employees
ORDER BY composite_satisfaction_score ASC
LIMIT 50;  -- Bottom 50 most dissatisfied employees


-- ============================================================
-- SECTION 9: BUSINESS TRAVEL IMPACT
-- ============================================================

SELECT
    BusinessTravel,
    COUNT(*) AS total,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrited,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome), 0) AS avg_income
FROM hr_employees
GROUP BY BusinessTravel
ORDER BY attrition_rate_pct DESC;


-- ============================================================
-- SECTION 10: ADVANCED — WINDOW FUNCTIONS & CTEs
-- ============================================================

-- 10.1 Rank departments by attrition rate using WINDOW function
WITH dept_attrition AS (
    SELECT
        Department,
        COUNT(*) AS total,
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrited,
        ROUND(
            SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
        ) AS attrition_rate_pct
    FROM hr_employees
    GROUP BY Department
)
SELECT
    Department,
    total,
    attrited,
    attrition_rate_pct,
    RANK() OVER (ORDER BY attrition_rate_pct DESC) AS attrition_rank
FROM dept_attrition;

-- 10.2 Running total of attrition by tenure (cumulative)
WITH tenure_data AS (
    SELECT
        YearsAtCompany,
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrited_count
    FROM hr_employees
    GROUP BY YearsAtCompany
)
SELECT
    YearsAtCompany,
    attrited_count,
    SUM(attrited_count) OVER (ORDER BY YearsAtCompany) AS cumulative_attrition
FROM tenure_data
ORDER BY YearsAtCompany;

-- 10.3 High-risk employee identification (CTE + multi-condition)
WITH risk_scoring AS (
    SELECT
        EmployeeID,
        Department,
        JobRole,
        MonthlyIncome,
        Attrition,
        (
            CASE WHEN OverTime = 'Yes'          THEN 2 ELSE 0 END +
            CASE WHEN JobSatisfaction <= 2       THEN 2 ELSE 0 END +
            CASE WHEN WorkLifeBalance <= 2       THEN 2 ELSE 0 END +
            CASE WHEN YearsAtCompany <= 2        THEN 1 ELSE 0 END +
            CASE WHEN MonthlyIncome < 3000       THEN 1 ELSE 0 END +
            CASE WHEN YearsSinceLastPromotion > 3 THEN 1 ELSE 0 END +
            CASE WHEN NumCompaniesWorked > 5     THEN 1 ELSE 0 END
        ) AS risk_score
    FROM hr_employees
)
SELECT
    EmployeeID,
    Department,
    JobRole,
    MonthlyIncome,
    Attrition,
    risk_score,
    CASE
        WHEN risk_score >= 6 THEN 'Critical Risk'
        WHEN risk_score >= 4 THEN 'High Risk'
        WHEN risk_score >= 2 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_category
FROM risk_scoring
ORDER BY risk_score DESC;

-- 10.4 Department-level summary for Power BI import
SELECT
    Department,
    JobRole,
    Gender,
    MaritalStatus,
    OverTime,
    CASE
        WHEN MonthlyIncome < 3000  THEN 'Low'
        WHEN MonthlyIncome < 7000  THEN 'Mid'
        WHEN MonthlyIncome < 12000 THEN 'High'
        ELSE 'Very High'
    END AS salary_band,
    CASE
        WHEN Age < 25 THEN 'Under 25'
        WHEN Age < 35 THEN '25-34'
        WHEN Age < 45 THEN '35-44'
        ELSE '45+'
    END AS age_group,
    CASE
        WHEN YearsAtCompany <= 2  THEN '0-2 Yrs'
        WHEN YearsAtCompany <= 5  THEN '3-5 Yrs'
        WHEN YearsAtCompany <= 10 THEN '6-10 Yrs'
        ELSE '10+ Yrs'
    END AS tenure_band,
    COUNT(*) AS employee_count,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrition_count,
    ROUND(AVG(MonthlyIncome), 0) AS avg_income,
    ROUND(AVG(JobSatisfaction), 2) AS avg_job_satisfaction,
    ROUND(AVG(WorkLifeBalance), 2) AS avg_wlb
FROM hr_employees
GROUP BY Department, JobRole, Gender, MaritalStatus, OverTime,
         salary_band, age_group, tenure_band
ORDER BY Department, attrition_count DESC;