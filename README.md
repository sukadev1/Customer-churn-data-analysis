
# 📊 Telecom Customer Churn Analytics (SQL)

## 📌 Objective
To analyze customer churn patterns, identify key churn drivers, and classify customer segments by risk and value using advanced SQL queries on a telecom dataset.

---

## 📦 Tools & Technologies
- **SQL Server Management Studio (SSMS)**
- **T-SQL**  
  (CTEs, Window Functions, Aggregations, CASE logic)

---

## 📁 Key Deliverables
- Cleaned and prepared the dataset (removed duplicates, handled nulls)
- Segmented customers by churn status: **Churned**, **Joined**, **Stayed**
- Identified:
  - Customers acquired in the last quarter
  - Key churn drivers: Offer availability, Contract type, Internet Type, Premium Tech Support
  - High-risk customer segments based on usage patterns
  - High-value customers at risk of churning
- Computed:
  - Churn percentage by service type
  - Average sales, tenure, and referrals
  - Customer value segmentation: **High**, **Medium**, **Low**
  - Contribution of each churn reason category

---

## 📊 SQL Techniques Applied
- **Data Profiling:** Duplicate detection, null handling
- **Aggregations & Grouping:** `SUM()`, `COUNT()`, `AVG()`, `ROUND()`
- **Window Functions:** `PERCENTILE_CONT()`, `ROW_NUMBER()`, `RANK()`
- **CTEs:** For layered and modular query building
- **CASE Statements:** For customer segmentation and risk scoring
- **Date Functions:** `DATEADD()`, `GETDATE()`, `DATEDIFF()`

---

## 📈 Business Insights Delivered
- Identified contracts and services most responsible for customer churn
- Pinpointed high-risk customer profiles for proactive retention strategies
- Flagged high-value customers showing early churn indicators
- Delivered actionable churn risk classifications for business decision-making

---
## 📂 Dataset
- 'telecom_customer_churn'— the telecom churn dataset used for analysis  
  *(available in the /Dataset folder of this repository)*


---

## 🚀 Outcome
A complete **SQL-driven churn analytics project** producing valuable business insights — presentation-ready for hiring managers or suitable for integrating into dashboard tools like **Power BI** or **Excel**.

---

---

## ⭐ How to Use
- Open **SQL Server Management Studio (SSMS)**
- Connect to your database
- Run `telecom_customer_churn_analysis.sql`
- Review insights in result sets or extend analysis as needed

---

## 📌 Connect with Me  
📧 ******.com  
🔗 [LinkedIn](https://www.linkedin.com/in/sukadevpatra)

