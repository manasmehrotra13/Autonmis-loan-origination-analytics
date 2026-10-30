-- Loan Origination System (LOS): the 6 KPIs on the dashboard (PostgreSQL).
-- Copied from my write-up of 15 May 2025 (docs/write-up.pdf).

-- Avg Cost Per Acquisition
SELECT
    TO_CHAR(DATE_TRUNC('month', lbi.applied_date), 'YYYY-MM-DD') AS applied_dates,
    cast(ROUND(AVG(lbi.cost_per_acquisition), 2)as float) AS avg_cost_per_acquisition
FROM los_fact_loan_journey lfj
JOIN los_dim_business_insights lbi ON lfj.loan_id = lbi.loan_id
GROUP BY applied_dates
ORDER BY applied_dates;

-- Total Applications Submitted Over Time
SELECT
    TO_CHAR(DATE_TRUNC('month', lbi.applied_date), 'YYYY-MM-DD') AS applied_dates,
    cast(COUNT(DISTINCT lfj.application_id)as int) AS total_applications_submitted
FROM los_fact_loan_journey lfj
JOIN los_dim_business_insights lbi ON lfj.loan_id = lbi.loan_id
WHERE lfj.application_id IS NOT NULL
GROUP BY applied_dates
ORDER BY applied_dates;

-- Overall Conversion Rate
SELECT
    TO_CHAR(DATE_TRUNC('month', lbi.applied_date), 'YYYY-MM-DD') AS applied_dates,
    cast(COUNT(DISTINCT lfj.application_id) * 100.0 / NULLIF(COUNT(DISTINCT lfj.lead_id), 0)as float) AS conversion_rate_percentage
FROM los_fact_loan_journey lfj
JOIN los_dim_business_insights lbi ON lfj.loan_id = lbi.loan_id
GROUP BY applied_dates
ORDER BY applied_dates;

-- Average Approved Amount
SELECT
    TO_CHAR(DATE_TRUNC('month', lfj.loan_start_date), 'YYYY-MM-DD') AS loan_start_date,
    cast(SUM(lfj.approved_amount)as float) AS total_approved_amount,
    cast(ROUND(AVG(lfj.approved_amount), 2)as float) AS avg_approved_amount
FROM los_fact_loan_journey lfj
WHERE lfj.approval_status = 'Approved'
GROUP BY loan_start_date
ORDER BY loan_start_date;

-- Loan Disbursal Metrics Over Time
SELECT
    TO_CHAR(DATE_TRUNC('month', lfj.disbursement_date), 'YYYY-MM-DD') AS disbursement_date,
    cast(SUM(lfj.disbursed_amount)as float) AS total_disbursed_amount,
    cast(ROUND(AVG(lfj.disbursed_amount), 2)as float) AS avg_disbursed_amount
FROM los_fact_loan_journey lfj
WHERE lfj.disbursed_amount IS NOT NULL
GROUP BY disbursement_date
ORDER BY disbursement_date;

-- Loan Declines Over Time
SELECT
    TO_CHAR(DATE_TRUNC('month', lbi.decline_date), 'YYYY-MM-DD') AS decline_date,
    cast(COUNT(*)as int) AS total_loans_declined,
    cast(ROUND(AVG(lfj.credit_score_at_decline), 0)as int) AS avg_credit_score_at_decline,
    cast(ROUND(AVG(lfj.income_at_decline), 2)as float) AS avg_income_at_decline
FROM los_fact_loan_journey lfj
JOIN los_dim_business_insights lbi ON lfj.loan_id = lbi.loan_id
WHERE lfj.approval_status = 'Declined'
GROUP BY lbi.decline_date
ORDER BY lbi.decline_date;
