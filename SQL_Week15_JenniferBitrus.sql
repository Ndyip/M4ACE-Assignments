--CTEs
WITH CTE_Employee as 
(SELECT FirstName, LastName, Gender, Salary
, COUNT(Gender) OVER (PARTITION by Gender) as TotalGender
, AVG(Salary) OVER (PARTITION by Gender) as AvgSalary
FROM EmployeeDemo emp
JOIN EmployeePay pay
ON emp.EmployeeID = pay.EmployeeID
WHERE Salary > '45000'
)
SELECT FirstName, LastName, Salary
FROM CTE_Employee 

--Temp Tables (Temporary Tables)
CREATE TABLE #Temp_Employee(
Employee_ID int,
JobTitle varchar(100),
Salary int
)
SELECT *
FROM #Temp_Employee

INSERT INTO #Temp_Employee
SELECT *
FROM EmployeePay

DROP TABLE IF EXISTS #Temp_Employee2
CREATE TABLE #Temp_Employee2(
JobTitle varchar (100),
EmployeesPerJob int,
AverageAge int, 
AveragePay int
)

INSERT INTO #Temp_Employee2
SELECT JobTitle, COUNT(JobTitle), AVG(Age), AVG(Salary)
FROM EmployeeDemo emp
JOIN EmployeePay pay
ON emp.EmployeeID = pay.EmployeeID
GROUP BY JobTitle

SELECT *
FROM #Temp_Employee2

--SUB QUERIES - a query within a query 
SELECT * 
FROM EmployeePay

--Subquery in Select
SELECT EmployeeID, Salary, (SELECT AVG(Salary) FROM EmployeePay) as AverageSalary
FROM EmployeePay

--Subquery in select - partition 
SELECT EmployeeID, Salary, AVG(Salary) over () as AverageSalary
FROM EmployeePay

--Subquery in from
SELECT a.EmployeeID, AverageSalary
from (select EmployeeID, Salary, AVG(Salary) over () as AverageSalary
from EmployeePay) a

--Subquery in where
SELECT EmployeeID, JobTitle, Salary
FROM EmployeePay
WHERE EmployeeID in (
	SELECT EmployeeID
	FROM EmployeeDemo
	WHERE Age > 30)


