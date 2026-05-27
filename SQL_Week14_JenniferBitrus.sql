CREATE TABLE EmployeeDemo
(EmployeeID int, FirstName varchar(50), LastName varchar(50), Age int, Gender varchar(50))

CREATE TABLE EmployeePay
(EmployeeID int, JobTitle varchar(50), Salary int)

INSERT INTO EmployeePay VALUES
(1001, 'HR', 45000),
(1002, 'HR', 45000),
(1003, 'Salesman', 60000),
(1004, 'Receptionist', 50000),
(1005, 'Accountant', 70000),
(1006, 'Regional Manager', 80000),
(1007, 'Supply Manager', 60000),
(1008, 'Salesman', 65000),
(1009, 'Accountant', 70000),
(1010, NULL, 47000),
(NULL, 'Salesman', 65000)

INSERT INTO EmployeeDemo VALUES
(1001, 'Angela', 'Burr', 31, 'Female'),
(1002, 'Mike', 'Scott', 35, 'Male'),
(1003, 'Kevin', 'Gates', 40, 'Male'),
(1004, 'Tiffany', 'Tyler', 32, 'Female'),
(1005, 'Jeff', 'Dahmer', 26, 'Male'),
(1006, 'Gill', 'Scot', 40, 'Female'),
(1007, 'Holly', 'Felix', 37, 'Female'),
(1008, 'Darryl', 'Palmer', 28, 'Male'),
(1009, 'Kelvin', 'Malone', 31, 'Male'),
(1011, 'Ryan', 'Howard', 28, 'Male'),
(NULL, 'Jenny', 'Fisher', NULL, NULL),
(1013, 'Tatum', 'Fitzpatrick', NULL, 'Male')

--Join Statement
SELECT EmployeeDemo.EmployeeID, FirstName, LastName, Salary
FROM EmployeeDemo
inner Join EmployeePay
ON EmployeeDemo.EmployeeID = EmployeePay.EmployeeID

----Union 
SELECT EmployeeID, FirstName, Age
FROM EmployeeDemo
UNION ALL
SELECT EmployeeID, JobTitle, Salary
FROM EmployeePay

--Case Statement1
SELECT FirstName, LastName, Age,
CASE
	WHEN Age > 30 THEN 'OLD'
	WHEN Age BETWEEN 27 AND 30 THEN 'Young'
	WHEN Age < 27 THEN 'Baby'
END AS AgeGroup
FROM EmployeeDemo
WHERE Age is NOT NULL
ORDER BY Age
--Case Statement2
SELECT FirstName, LAstName, JobTitle, Salary,
CASE
	WHEN JobTitle = 'Salesman' THEN Salary + (Salary * .50)
	WHEN JobTitle = 'Accountant' THEN Salary + (Salary * .20)
	WHEN JobTitle = 'HR' THEN Salary + (Salary * .30)
	ELSE Salary + (Salary * .10)
END AS SalaryAfterRaise
FROM EmployeeDemo
JOIN EmployeePay
ON EmployeeDemo.EmployeeID = EmployeePay.EmployeeID

--Updating/Deleting data
SELECT *
FROM EmployeeDemo
UPDATE EmployeeDemo
SET Age = 31, Gender = 'Female'
WHERE EmployeeID = 1012
UPDATE EmployeeDemo
SET Age = 36
WHERE EmployeeID = 1013

--Deleting data
DELETE FROM EmployeeDemo
WHERE EmployeeID = 1004 



