-- Customer churn analytics

-- 1.check for duplicates
select Customer_ID,count(*) as occurences
from [dbo].[telecom_customer_churn]
group by Customer_ID
having count(*) >1;
--2.How many Customers do we have currently?
select count(distinct Customer_ID) 
from telecom_customer_churn;
--How many customers joined the company during the last quarter? 
WITH LastQuarter AS (
		SELECT DATEADD(MONTH, -3, GETDATE()) AS "StartofLastQuarter"
		)
SELECT COUNT(*) AS customer_joined_last_quarter  /*joined date*/
FROM [dbo].[telecom_customer_churn]
WHERE DATEADD(MONTH, -Tenure_in_Months, GETDATE()) >= 
			(SELECT StartofLastQuarter 
		 FROM LastQuarter);
/*What is the customer profile for a customer that churned, joined, 
and stayed? Are they different?*/
SELECT Customer_Status, Gender, Married, 
       AVG(CAST (age AS INT)) AS Avg_Age, 
       AVG(CAST (Number_of_Dependents AS INT)) AS Avg_Dependents,
       COUNT(*) AS Total_Customers
FROM [dbo].[telecom_customer_churn]
GROUP BY Customer_Status, Gender, Married
ORDER BY Customer_Status;
--5. What are the key drivers for churn
SELECT Churn_Category, Churn_Reason, COUNT(*) AS customers
FROM [dbo].[telecom_customer_churn]
WHERE Customer_Status = 'Churned'
GROUP BY Churn_Category, Churn_Reason
ORDER BY COUNT(*) DESC;
--6. What Contract are Churners on?
SELECT Contract
		,COUNT(*) AS customers
		,ROUND((CAST(COUNT(*) AS FLOAT) * 100.0 / SUM(COUNT(*)) OVER ()), 2) AS per
FROM [dbo].[telecom_customer_churn]
WHERE Customer_Status = 'Churned'
GROUP BY Contract
ORDER BY COUNT(*) DESC;
--7. Do Churners have access to Premium Tech Support?
SELECT Premium_Tech_Support, count(*) AS customers
, ROUND(cast(COUNT(*) as float) * 100.0 / SUM(COUNT(*)) OVER () , 2)   AS per
FROM [dbo].[telecom_customer_churn]
WHERE Customer_Status = 'Churned'
GROUP BY Premium_Tech_Support
ORDER BY COUNT(*) DESC;
---8. What Internet Type do Churned Customers use?
SELECT Internet_Type, count(*) AS customers
, ROUND(cast(COUNT(*) as float) * 100.0 / SUM(COUNT(*)) OVER () , 2)AS per
FROM [dbo].[telecom_customer_churn]
WHERE Customer_Status = 'Churned'
GROUP BY Internet_Type
ORDER BY COUNT(*) DESC;
---9. What Offers are Churned Customers on?
SELECT [Offer], count(*) AS customers
,ROUND(cast(COUNT(*) as float) * 100.0 / SUM(COUNT(*)) OVER () , 2)AS per
FROM [dbo].[telecom_customer_churn]
WHERE Customer_Status = 'Churned'
GROUP BY [Offer]
ORDER BY COUNT(*) DESC;
--10. Risk Level of Customers
SELECT Customer_ID
	,[Offer]
	,Premium_Tech_Support
	,[Contract]
	,Internet_Type 
	,CASE
		WHEN(
			CASE WHEN [Offer] = 'None' THEN 1 ELSE 0 END +
			CASE WHEN Premium_Tech_Support = 'No' THEN 1 ELSE 0 END +
			CASE WHEN [Contract] = 'Month-to-Month' THEN 1 ELSE 0 END +
			CASE WHEN Internet_Type = 'Fiber Optic' THEN 1 ELSE 0 END) 
			>=3 THEN 'High Risk'
		WHEN(
			CASE WHEN [Offer] = 'None' THEN 1 ELSE 0 END +
			CASE WHEN Premium_Tech_Support = 'No' THEN 1 ELSE 0 END +
			CASE WHEN [Contract] = 'Month-to-Month' THEN 1 ELSE 0 END +
			CASE WHEN Internet_Type = 'Fiber Optic' THEN 1 ELSE 0 END) 
			=2 THEN 'Medium Risk'
		ELSE 'Low Risk'
	END AS "Risk Level"
FROM [dbo].[telecom_customer_churn]
WHERE Customer_Status != 'Churned'
--11.Risk Level and Value of Customers
WITH MedianCharge AS (
    SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY [Monthly_Charge]) 
            OVER () AS MedianMonthlyCharge
    FROM [dbo].[telecom_customer_churn]
)
SELECT 
    Customer_ID,
    Number_of_Referrals,
    Monthly_Charge,
    Tenure_in_Months,
    CASE
        WHEN Tenure_in_Months >= 9 
             AND Monthly_Charge >= (SELECT TOP 1 MedianMonthlyCharge FROM MedianCharge)
             AND Number_of_Referrals > 0 
            THEN 'High'
        WHEN (Tenure_in_Months >= 9 AND Monthly_Charge >= (SELECT TOP 1 MedianMonthlyCharge FROM MedianCharge))
             OR (Tenure_in_Months >= 9 AND Number_of_Referrals > 0)
             OR (Monthly_Charge >= (SELECT TOP 1 MedianMonthlyCharge FROM MedianCharge) AND Number_of_Referrals > 0)
            THEN 'Medium'
        ELSE 'Low'
    END AS CustomerValue
FROM [dbo].[telecom_customer_churn];
--12.High value customers at risk of churning?
WITH CustomerClassification AS (
    SELECT 
        Customer_ID, 
        Tenure_in_Months, 
        Monthly_Charge, 
        Number_of_Referrals,
        Customer_Status,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CAST([Monthly_Charge] AS DECIMAL)) OVER () AS MedianMonthlyCharge,
        Premium_Tech_Support,
        Internet_Type,
        [Offer],
        [Contract],
        -- Risk Level classification
        CASE
            WHEN 
                (CASE WHEN Premium_Tech_Support = 'No' THEN 1 ELSE 0 END +
                 CASE WHEN Internet_Type = 'Fiber Optic' THEN 1 ELSE 0 END +
                 CASE WHEN [Offer] = 'None' THEN 1 ELSE 0 END +
                 CASE WHEN [Contract] = 'Month-to-Month' THEN 1 ELSE 0 END
                ) >= 3 THEN 'High Risk'
            WHEN 
                (CASE WHEN Premium_Tech_Support = 'No' THEN 1 ELSE 0 END +
                 CASE WHEN Internet_Type = 'Fiber Optic' THEN 1 ELSE 0 END +
                 CASE WHEN [Offer] = 'None' THEN 1 ELSE 0 END +
                 CASE WHEN [Contract] = 'Month-to-Month' THEN 1 ELSE 0 END
                ) = 2 THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS CustomerRiskLevel
    FROM [dbo].[telecom_customer_churn]
),
CustomerValueClassification AS (
    SELECT 
        *,
        CASE
    WHEN Tenure_in_Months >= 9 AND Monthly_Charge >= MedianMonthlyCharge AND Number_of_Referrals > 0 THEN 'High'
    WHEN Tenure_in_Months >= 9 AND (Monthly_Charge >= MedianMonthlyCharge OR Number_of_Referrals > 0) THEN 'Medium'
    ELSE 'Low'
END AS CustomerValue
    FROM CustomerClassification
)
SELECT 
    Customer_ID,
    Tenure_in_Months,
    Monthly_Charge,
    Number_of_Referrals,
    Customer_Status,
    CustomerValue,
    Premium_Tech_Support,
    Internet_Type,
    [Offer],
    [Contract],
    CustomerRiskLevel
FROM 
    CustomerValueClassification
WHERE 
    CustomerValue = 'High'
    AND CustomerRiskLevel = 'High Risk'
    AND Customer_Status != 'Churned'
ORDER BY 
    Monthly_Charge DESC;
