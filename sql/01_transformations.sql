-- Loan Origination System (LOS): data transformation queries (PostgreSQL).
-- Copied from my write-up of 15 May 2025 (docs/write-up.pdf). All the data is generated.
-- Looking back, I would change the joins in the first query: see "Looking back" in the README.

--1. Merging into fact_loan_journey (Loan process tracking)
DROP TABLE IF EXISTS los_fact_loan_journey ;
CREATE TABLE IF NOT EXISTS los_fact_loan_journey AS
SELECT
    fl.lead_id, fl.customer_id,fl.lead_source,fl.lead_status,fl.created_date as lead_created_date,
    fa.application_id, fa.loan_id, fa.application_status_id, fa.loan_amount, fa.tenure, fa.interest_rate AS applied_interest_rate,fa.applied_date as application_applied_date,fa.region_id, fa.channel_id, fa.agent_id,
    fu.underwriting_id, fu.risk_score, fu.approval_status,
    fu.approved_amount,fu.requested_amount,fu.credit_score,fu.processing_time_days, fu.decision_date,
    fd.disbursement_id, fd.disbursed_amount, fd.disbursement_date, fd.loan_start_date, fd.loan_end_date, fd.repayment_term_months,
    fd.interest_rate AS final_interest_rate,
    fdec.decline_id, fdec.decline_reason_id, fdec.credit_score_at_decline, fdec.income_at_decline,
    fdec.loan_amount_requested,fdec.decline_date

FROM fact_leads fl
JOIN fact_applications fa ON fl.customer_id = fa.customer_id
JOIN fact_underwriting fu ON fa.application_id = fu.application_id
JOIN fact_disbursements fd ON fa.application_id = fd.application_id
JOIN fact_declines fdec ON fa.application_id = fdec.application_id;


--2. Merging into dim_customer_details (Customer & Feedback details)
DROP TABLE IF EXISTS los_dim_customer_details ;
CREATE TABLE IF NOT EXISTS los_dim_customer_details AS
SELECT
    dc.customer_id, dc.first_name as cust_first_name, dc.last_name as cust_last_name, dc.dob as cust_DOB, dc.gender as cust_gender,
    dc.income as cust_income, dc.employment_status as cust_employment_status, dc.credit_score as cust_credit_score, dc.address as
    cust_address, dc.region_id,
    fc.feedback_id, fc.application_id, fc.agent_id, fc.feedback_score, fc.processing_time_satisfaction, fc.communication_satisfaction,
    fc.ease_of_application, fc.improvement_suggestions
FROM dim_customers dc
JOIN fact_customer_feedback fc ON dc.customer_id = fc.customer_id;


--3. Merging into dim_business_insights (Loan, Channel, Agent, Performance)
DROP TABLE IF EXISTS los_dim_business_insights ;
CREATE TABLE IF NOT EXISTS los_dim_business_insights AS
SELECT
    dl.loan_id, dl.loan_type, dl.interest_rate, dl.max_tenure, dl.min_amount, dl.max_amount,dl.eligibility_criteria,
    fa.applied_date,
    da.status_id, da.status_name, da.description AS status_description,
    dr.region_id, dr.country, dr.state, dr.city, dr.postal_code,
    dch.channel_id, dch.channel_name, dch.channel_type, dch.cost_per_acquisition,
    dd.reason_id, dd.reason_name, dd.risk_category, dd.mitigation_strategy,
    dag.agent_id, dag.first_name AS agent_first_name, dag.last_name AS agent_last_name, dag.assigned_channel_id, dag.experience_years,
    dag.performance_rating,
    fcp.performance_id, fcp.leads_generated, fcp.applications_submitted, fcp.conversion_rate, fcp.cost_per_lead, fcp.revenue_generated,
    fd.decline_date
FROM dim_loans dl
JOIN fact_applications fa ON dl.loan_id = fa.loan_id
JOIN dim_application_status da ON fa.application_status_id = da.status_id
JOIN dim_regions dr ON fa.region_id = dr.region_id
JOIN dim_channels dch ON fa.channel_id = dch.channel_id
JOIN dim_agents dag ON fa.agent_id = dag.agent_id
JOIN fact_channel_performance fcp ON dch.channel_id = fcp.channel_id
JOIN fact_declines fd ON fa.application_id = fd.application_id
JOIN dim_decline_reasons dd ON fd.decline_reason_id = dd.reason_id;
