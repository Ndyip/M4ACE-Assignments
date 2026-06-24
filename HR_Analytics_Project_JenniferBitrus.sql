CREATE DATABASE HR_Analysis;
GO

USE HR_Analysis;

--CLEANING THE DATA
SELECT TOP 100 *
FROM HR_Data 

--count of all our data
SELECT COUNT(*)
FROM HR_Data

--Checking for missing values
SELECT
    SUM(CASE WHEN first_name IS NULL THEN 1 ELSE 0 END) AS Missing_FirstName,
    SUM(CASE WHEN birthdate IS NULL THEN 1 ELSE 0 END) AS Missing_Birthdate,
    SUM(CASE WHEN department IS NULL THEN 1 ELSE 0 END) AS Missing_Department
FROM HR_Data;

--Correcting misspelling
UPDATE HR_Data
SET jobtitle = 'Relationship Manager'
WHERE jobtitle = 'Relationshiop Manager';

--setting the birthyear to the same format

ALTER TABLE HR_Data
ADD BirthDate_Clean DATE,
    HireDate_Clean DATE,
    TermDate_Clean DATE

--Setting birthdate, hire date and term date to a uniform format

UPDATE HR_Data
SET BirthDate_Clean =
COALESCE(
        TRY_CONVERT(DATE, birthdate, 1),
        TRY_CONVERT(DATE, birthdate, 101),
        TRY_CONVERT(DATE, birthdate, 110)
    );

UPDATE HR_Data
SET HireDate_Clean = 
COALESCE(
        TRY_CONVERT(DATE, hire_date, 1),
        TRY_CONVERT(DATE, hire_date, 101),
        TRY_CONVERT(DATE, hire_date, 110)
    );

UPDATE HR_Data
SET TermDate_Clean = 
COALESCE(
        TRY_CONVERT(DATE,termdate, 1),
        TRY_CONVERT(DATE, termdate, 101),
        TRY_CONVERT(DATE, termdate, 110)
    );

UPDATE HR_Data
SET TermDate_Clean =
    TRY_CONVERT(DATE, LEFT(termdate, 10))
WHERE termdate IS NOT NULL;

--Checking duplicate employee
SELECT id, COUNT(*) AS DuplicateCount
FROM HR_Data
GROUP BY id
HAVING COUNT(*) > 1;

--Setting employee fullname
ALTER TABLE HR_Data
ADD FullName VARCHAR(100);

UPDATE HR_Data
SET FullName =
    first_name + ' ' + last_name;

--Calculating employee age from birthdate
ALTER TABLE HR_Data
ADD Age INT;

SELECT TOP 100 *
FROM HR_Data 

UPDATE HR_Data
SET Age =
DATEDIFF(YEAR, BirthDate_Clean, GETDATE());

--EMPLOYEE PERFORMANCE

--EMPLOYEES BY DEPARTMENT
SELECT
    department,
    COUNT(*) AS EmployeeCount
FROM HR_Data
GROUP BY department
ORDER BY EmployeeCount DESC;

--EMPLOYEES BY JOBTITLE
SELECT
    jobtitle,
    COUNT(*) AS TotalEmployees
FROM HR_Data
GROUP BY jobtitle
ORDER BY TotalEmployees DESC;

--GENDER DISTRIBUTION
SELECT
    gender,
    COUNT(*) AS Employees
FROM HR_Data
GROUP BY gender;

--RACE DISTRIBUTION
SELECT
    race,
    COUNT(*) AS Employees
FROM HR_Data
GROUP BY race
ORDER BY Employees DESC;

--EMPLOYEE RETENTION ANALYSIS
--active versus terminated employees
SELECT
    CASE
        WHEN termdate IS NULL THEN 'Active'
        ELSE 'Terminated'
    END AS EmployeeStatus,
    COUNT(*) AS TotalEmployees
FROM HR_Data
GROUP BY
    CASE
        WHEN termdate IS NULL THEN 'Active'
        ELSE 'Terminated'
    END;

--Average employee tenure
SELECT
AVG(
    DATEDIFF(
        YEAR,
        HireDate_Clean,
        ISNULL(TermDate_Clean,GETDATE())
    )
) AS AvgTenureYears
FROM HR_Data;

--Turnover rate by department i.e number of employees left
SELECT
    department,
    COUNT(*) AS TotalEmployees,
    SUM(
        CASE
            WHEN termdate IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS EmployeesLeft
FROM HR_Data
GROUP BY department;

--Hiring Trend, how many employees were hired every year
SELECT
    YEAR(HireDate_Clean) AS HireYear,
    COUNT(*) AS EmployeesHired 
FROM HR_Data
GROUP BY YEAR(HireDate_Clean)
ORDER BY HireYear;

--SALARY ANALYSIS
--we don't have a salary column in our dataset so I created my own salary table.

--Joining salaries to the employees
SELECT
    h.FullName,
    h.department,
    s.salary
FROM HR_Data h
INNER JOIN EmployeeSalary s
ON h.id = s.id;

--Average salary by department which department are paid the most
SELECT
    h.department,
    AVG(s.salary) AS AvgSalary
FROM HR_Data h
INNER JOIN EmployeeSalary s
    ON h.id = s.id
GROUP BY h.department
ORDER BY AvgSalary DESC;

--Highest paid employees
SELECT TOP 10
    h.FullName,
    h.jobtitle,
    s.salary
FROM HR_Data h
INNER JOIN EmployeeSalary s
    ON h.id = s.id
ORDER BY s.salary DESC;

--Average salary by job title
SELECT
    h.jobtitle,
    AVG(s.salary) AS AvgSalary
FROM HR_Data h
INNER JOIN EmployeeSalary s
    ON h.id = s.id
GROUP BY h.jobtitle
ORDER BY AvgSalary DESC;

--Salary distribution by gender
SELECT
    h.gender,
    AVG(s.salary) AS AvgSalary
FROM HR_Data h
INNER JOIN EmployeeSalary s
    ON h.id = s.id
GROUP BY h.gender;

--Salary distribution by race
SELECT
    h.race,
    AVG(s.salary) AS AvgSalary
FROM HR_Data h
INNER JOIN EmployeeSalary s
    ON h.id = s.id
GROUP BY h.race
ORDER BY AvgSalary DESC;

--Salary summary by departments
WITH DepartmentSalary AS
(
    SELECT
        h.department,
        COUNT(*) AS EmployeeCount,
        AVG(s.salary) AS AvgSalary,
        MAX(s.salary) AS HighestSalary,
        MIN(s.salary) AS LowestSalary
    FROM HR_Data h
    INNER JOIN EmployeeSalary s
        ON h.id = s.id
    GROUP BY h.department
)

SELECT *
FROM DepartmentSalary
ORDER BY AvgSalary DESC;

--departments with the most employee counts.

WITH DeptCount AS
(
    SELECT
        department,
        COUNT(*) AS Employees
    FROM HR_Data
    GROUP BY department
)

SELECT *
FROM DeptCount
WHERE Employees >
(
    SELECT AVG(Employees)
    FROM DeptCount
);

--ranking departments by size

SELECT
    department,
    COUNT(*) AS Employees,
    RANK() OVER
    (
        ORDER BY COUNT(*) DESC
    ) AS DeptRank
FROM HR_Data
GROUP BY department;

--running total hired employees from 2000 till 2020

SELECT
    YEAR(HireDate_Clean) AS HireYear,
    COUNT(*) AS Hires,
    SUM(COUNT(*))
        OVER
        (
            ORDER BY YEAR(HireDate_Clean)
        ) AS RunningTotal
FROM HR_Data
GROUP BY YEAR(HireDate_Clean);


--department summary 
WITH DepartmentStats AS
(
    SELECT
        department,
        COUNT(*) AS EmployeeCount,
        SUM(
            CASE
                WHEN termdate IS NOT NULL
                THEN 1
                ELSE 0
            END
        ) AS EmployeesLeft
    FROM HR_Data
    GROUP BY department
)

SELECT
    department,
    EmployeeCount,
    EmployeesLeft,

    ROUND(
        EmployeesLeft * 100.0 /
        EmployeeCount,
        2
    ) AS TurnoverRate,

    RANK() OVER
    (
        ORDER BY EmployeeCount DESC
    ) AS DepartmentRank

FROM DepartmentStats
ORDER BY DepartmentRank;


--Top earners by Depratment
WITH SalaryRanking AS
(
    SELECT
        h.department,
        h.FullName,
        h.jobtitle,
        s.salary,

        ROW_NUMBER() OVER
        (
            PARTITION BY h.department
            ORDER BY s.salary DESC
        ) AS SalaryPosition

    FROM HR_Data h

    INNER JOIN EmployeeSalary s
        ON h.id = s.id
)

SELECT
    department,
    FullName,
    jobtitle,
    salary
FROM SalaryRanking
WHERE SalaryPosition = 1
ORDER BY salary DESC;

--Final report on hr data
WITH EmployeeMetrics AS
(
    SELECT
        h.id,
        h.FullName,
        h.department,
        h.jobtitle,
        h.hiredate_clean,
        h.termdate_clean,
        s.salary,

        DATEDIFF
        (
            YEAR,
            h.hiredate_clean,
            ISNULL(h.termdate_clean, GETDATE())
        ) AS TenureYears,

        CASE
            WHEN h.termdate_clean IS NULL
            THEN 'Active'
            ELSE 'Terminated'
        END AS EmploymentStatus

    FROM HR_Data h

    INNER JOIN EmployeeSalary s
        ON h.id = s.id
),

DepartmentReport AS
(
    SELECT
        department,

        COUNT(*) AS EmployeeCount,

        SUM(
            CASE
                WHEN EmploymentStatus = 'Terminated'
                THEN 1
                ELSE 0
            END
        ) AS EmployeesLeft,

        AVG(TenureYears) AS AvgTenure,

        AVG(salary) AS AvgSalary,

        MAX(salary) AS HighestSalary,

        MIN(salary) AS LowestSalary

    FROM EmployeeMetrics

    GROUP BY department
)

SELECT

    department,

    EmployeeCount,

    EmployeesLeft,

    ROUND
    (
        EmployeesLeft * 100.0 /
        EmployeeCount,
        2
    ) AS TurnoverRate,

    ROUND(AvgTenure,2) AS AvgTenureYears,

    CAST(AvgSalary AS DECIMAL(10,2)) AS AvgSalary,

    HighestSalary,

    LowestSalary,

    RANK() OVER
    (
        ORDER BY AvgSalary DESC
    ) AS SalaryRank,

    RANK() OVER
    (
        ORDER BY AvgTenure DESC
    ) AS RetentionRank, 

    RANK() OVER
    (
        ORDER BY EmployeeCount DESC
    ) AS PerformanceRank

FROM DepartmentReport

ORDER BY SalaryRank;
