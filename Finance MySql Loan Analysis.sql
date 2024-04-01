create database project_1;
use project_1;
alter table finance drop column month_column;
select * from finance;
-- 1-Total Loan Applications: We need to calculate the total number of loan applications received during a 
-- specified period. Additionally, it is essential to monitor the Month-to-Date (MTD) Loan Applications 
-- and track changes Month-over-Month (MoM).
select count(id) as total_application, monthname(issue_date) as month_name
from finance group by monthname(issue_date), year(issue_date) order by total_application;

select issue_month, total_application,
t.total_application-lag(total_application) over() as track_change from 
(select issue_month, count(id) as total_application from finance
group by issue_month order by
FIELD(issue_month, 'January', 'February', 'March', 'April', 'May', 'June', 
               'July', 'August', 'September', 'October', 'November', 'December')) t;

select issue_month, total_application,
t.total_application-lag(total_application) over() as track_change,
total_good_loans, total_current_loans, total_bad_loans from 
(select issue_month, count(id) as total_application,
COUNT(CASE WHEN loan_status = 'Fully Paid' THEN 1 END) AS total_good_loans,
COUNT(CASE WHEN loan_status = 'Current' THEN 1 END) AS total_current_loans,
COUNT(CASE WHEN loan_status = 'Charged off' THEN 1 END) AS total_bad_loans from finance
group by issue_month order by
FIELD(issue_month, 'January', 'February', 'March', 'April', 'May', 'June', 
               'July', 'August', 'September', 'October', 'November', 'December'))t;

-- Q2-Total Funded Amount: Understanding the total amount of funds disbursed as loans is crucial.
-- We also want to keep an eye on the MTD Total Funded Amount and analyse the Month-over-Month (MoM)
--  changes in this metric.
select issue_month, fund_disbursed,good_loan_amount,current_loan_amount,bad_loan_amount,
t.fund_disbursed-lag(fund_disbursed) over() as track_month_fund from
(select issue_month, sum(loan_amount) as fund_disbursed,
sum(CASE WHEN loan_status = 'Fully Paid' THEN loan_amount else 0 END) AS good_loan_amount,
sum(CASE WHEN loan_status = 'Current' THEN loan_amount else 0 END) AS current_loan_amount,
sum(CASE WHEN loan_status = 'Charged off' THEN loan_amount else 0 END) AS bad_loan_amount from finance
group by issue_month order by FIELD(issue_month, 'January', 'February', 'March', 'April', 'May', 'June', 
               'July', 'August', 'September', 'October', 'November', 'December'))t;

select sum(loan_amount) as fund_disbursed, monthname(issue_date) from finance
group by monthname(issue_date), year(issue_date) order by monthname(issue_date);

-- Q3- Total Amount Received: Tracking the total amount received from borrowers is essential for assessing the bank's
--  cash flow and loan repayment. We should analyse the Month-to-Date (MTD) Total Amount Received
-- and observe the Month-over-Month (MoM) changes.

select issue_month, amount_received,amount_disbursed,
t.amount_received-lag(amount_received) over() as amount_received_change from
(select issue_month, sum(total_payment) as amount_received,
sum(loan_amount) as amount_disbursed from finance
group by issue_month order by FIELD(issue_month, 'January', 'February', 'March', 'April', 'May', 'June', 
               'July', 'August', 'September', 'October', 'November', 'December'))t;

-- Q4-Average Interest Rate: Calculating the average interest rate across all loans, MTD,
-- and monitoring the Month-over-Month (MoM) variations in interest rates will provide insights
-- into our lending portfolio's overall cost.

select issue_month, avg_intrest,
round(t.avg_intrest-lag(avg_intrest) over(),4)*100 as int_rate_change from
(select issue_month, round(avg(int_rate),4) as avg_intrest from finance
group by issue_month order by FIELD(issue_month, 'January', 'February', 'March', 'April', 'May', 'June', 
               'July', 'August', 'September', 'October', 'November', 'December'))t;

-- Q5-Average Debt-to-Income Ratio (DTI): Evaluating the average DTI for our borrowers 
-- helps us gauge their financial health. We need to compute the average DTI for all loans,
-- MTD, and track Month-over-Month (MoM) fluctuations.
select purpose, round(avg(dti),4)*100 as avg_dti from finance group by purpose;

select issue_month, purpose, avg_dti,
round(t.avg_dti-lag(avg_dti) over(),4) as avg_dti_change from
(select issue_month, purpose, round(avg(dti),4)*100 as avg_dti from finance
group by issue_month, purpose order by FIELD(issue_month, 'January', 'February', 'March', 'April', 'May', 'June', 
               'July', 'August', 'September', 'October', 'November', 'December'))t;

-- Q6-Good Loan Application Percentage: We need to calculate the percentage of loan applications 
-- classified as 'Good Loans.' This category includes loans with a loan status of 'Fully Paid' and 'Current.'
select count(id) as total_loan, count(good_loan) as total_good_loan, 
(count(good_loan)/count(id))*100 as total_percentage_good_loan from
(select *,
case
when loan_status='fully paid' or loan_status='current' then 1 end as good_loan from finance)t;

SELECT 
COUNT(CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN 1 END) AS good_loans_count,
COUNT(*) AS total_loans_count,
(COUNT(CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN 1 END) / COUNT(*)) * 100
AS percentage_good_loans
FROM finance;

select 
count(id) as total_loan,
count(case when loan_status='fully paid' then 1 end) as total_good_loan,
count(case when loan_status='current' then 1 end) as total_current_loan,
count(case when loan_status='charged off' then 1 end) as total_bad_loan from finance;

SELECT loan_status, count(*) from finance group by loan_status;

-- Q7-Good Loan Funded Amount: Determining the total amount of funds disbursed as 'Good Loans.'
-- This includes the principal amounts of loans with a loan status of 'Fully Paid' and 'Current.'
select sum(loan_amount) as good_loan_funded_amount from finance
where loan_status='Fully Paid' or loan_status='Current';

-- Q8-Good Loan Total Received Amount: Tracking the total amount received from borrowers for 'Good Loans,'
-- which encompasses all payments made on loans with a loan status of 'Fully Paid' and 'Current.'
select sum(total_payment) as good_loan_received_amount from finance
where loan_status='Fully Paid' or loan_status='Current';

-- Q9-Bad Loan Application Percentage: Calculating the percentage of loan applications categorized as 'Bad Loans.'
-- This category specifically includes loans with a loan status of 'Charged Off.'
select count(id) as total_loan, count(bad_loan) as total_bad_loan, 
(count(bad_loan)/count(id))*100 as total_percentage_bad_loan from
(select *,
case
when loan_status='Charged Off' then 1 end as bad_loan from finance)t;