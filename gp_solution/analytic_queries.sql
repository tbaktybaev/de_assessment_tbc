/*
    1) monthly_sales (CTE): This part calculates the total sales (total_sales) and number of transactions
     (total_transactions) for each month, using the to_char() function to group the data by month.
*/
-- calculating the total sales and number of transactions for each month
with monthly_sales as (
    select
        to_char(purchase_date, 'YYYY-MM') as month, -- formatting date as year-month
        sum(total_amount) as total_sales, -- total amount sales for month
        count(transaction_id) as total_transactions -- total quantity sales for month
    from sales_transactions
    group by to_char(purchase_date, 'YYYY-MM')
    order by month
)
/*
    2) 3-month moving average:

    * The avg() window function, using rows between 2 preceding and current rows, calculates a moving average
     for the current and two preceding months. 
    * Round() is used to round the result to 2 decimal places.
    
    This query will perform the analysis required in the job by providing the monthly sales and their 3-month moving average.
*/
-- calculating the 3-month moving average of sales amount for each month
select
    month,
    total_sales,
    total_transactions,
    round(avg(total_sales) over (order by month rows between 2 preceding and current row), 2) as moving_avg_sales -- moving average
from monthly_sales;
