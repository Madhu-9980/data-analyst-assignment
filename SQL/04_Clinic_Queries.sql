-- Q1: Revenue from each sales channel
SELECT 
    sales_channel,
    SUM(amount) AS revenue
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY sales_channel;

-- Q2: Top 10 most valuable customers
SELECT 
    uid,
    SUM(amount) AS total_spent
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;

-- Q3: Month-wise revenue, expense, profit and status
SELECT 
    month,
    revenue,
    expense,
    (revenue - expense) AS profit,
    CASE 
        WHEN (revenue - expense) > 0 THEN 'Profitable'
        ELSE 'Not Profitable'
    END AS status
FROM (
    SELECT 
        MONTH(cs.datetime) AS month,
        SUM(cs.amount) AS revenue,
        COALESCE(SUM(e.amount), 0) AS expense
    FROM clinic_sales cs
    LEFT JOIN expenses e 
        ON cs.cid = e.cid 
        AND MONTH(cs.datetime) = MONTH(e.datetime)
    WHERE YEAR(cs.datetime) = 2021
    GROUP BY month
) t;

-- Q4: Most profitable clinic per city
SELECT *
FROM (
    SELECT 
        c.city,
        cs.cid,
        SUM(cs.amount - COALESCE(e.amount,0)) AS profit,
        RANK() OVER (PARTITION BY c.city ORDER BY SUM(cs.amount - COALESCE(e.amount,0)) DESC) AS rnk
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    LEFT JOIN expenses e ON cs.cid = e.cid
    GROUP BY c.city, cs.cid
) t
WHERE rnk = 1;

-- Q5: Second least profitable clinic per state
SELECT *
FROM (
    SELECT 
        c.state,
        cs.cid,
        SUM(cs.amount - COALESCE(e.amount,0)) AS profit,
        RANK() OVER (PARTITION BY c.state ORDER BY SUM(cs.amount - COALESCE(e.amount,0))) AS rnk
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    LEFT JOIN expenses e ON cs.cid = e.cid
    GROUP BY c.state, cs.cid
) t
WHERE rnk = 2;