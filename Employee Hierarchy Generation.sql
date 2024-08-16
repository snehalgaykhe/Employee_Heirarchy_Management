
create database FinalProjectSQLH;

use FinalProjectSQLH;

CREATE TABLE EMPLOYEE_MASTER (
    EMPLOYEEID VARCHAR(20) PRIMARY KEY,
    REPORTINGTO VARCHAR(MAX), -- Assuming it references EMPLOYEEID of another employee
    EMAILID NVARCHAR(MAX)
);


INSERT INTO EMPLOYEE_MASTER (EMPLOYEEID, REPORTINGTO, EMAILID)
VALUES ('H1', NULL, 'john.doe@example.com'),
       ('H2', NULL, 'jane.smith@domain.com'),
       ('H3', 'H1', 'alice.jones@example.com'),
       ('H4', 'H1', 'bob.white@example.com'),
       ('H5', 'H3', 'charlie.brown@example.com'),
	   ('H6', 'H3', 'david.green@example.com'),
       ('H7', 'H4', 'emily.gray@example.com'),
	   ('H8', 'H4', 'frankwilson@example.com'),
	   ('H9', 'H5', 'george.harris@example.com'),
	   ('H10', 'H5', 'hannah.taylor@example.com'),
       ('H11', 'H6', 'irene.martin@example.com'),
	   ('H12', 'H6', 'jackroberts@example.com'),
       ('H13', 'H7', 'kate.evans@example.com'),
	   ('H14', 'H7', 'laura.hall@example.com'),
       ('H15', 'H8', 'mike.anderson@example.com'),
	   ('H16', 'H8', 'natalie.c1ark@example.com'),
       ('H17', 'H9', 'oliver.davis@example.com'),
	   ('H18', 'H9', 'peter.edwards@example.com'),
       ('H19', 'H10', 'quinn.fisher@example.com'),
	   ('H20', 'H10', 'rachel.garcia@examp1e.com'),
       ('H21', 'H11', 'sarah.hernandez@example.com'),
	   ('H22', 'H11', 'thomas.1ee@example.com'),
       ('H23', 'H12', 'ursula.lopez@example.com'),
	   ('H24', 'H12', 'victor.martinez@example.com'),
       ('H25', 'H13', 'william.nguyen@example.com'),
	   ('H26', 'H13', 'xavier.ortiz@example.com'),
       ('H27', 'H14', 'yvonne.perez@example.com'),
	   ('H28', 'H14', 'zoe.quinn@example.com'),
       ('H29', 'H15', 'adam.robinson@example.com'),
	   ('H30', 'H15', 'barbara.smith@examp1e.com');


CREATE TABLE Employee_Hierarchy (
    EMPLOYEEID VARCHAR(20) PRIMARY KEY,
    REPORTINGTO NVARCHAR(MAX),
    EMAILID NVARCHAR(MAX),
    LEVEL INT,
    FIRSTNAME NVARCHAR(MAX),
    LASTNAME NVARCHAR(MAX)
);


CREATE PROCEDURE SP_hierarchyF
AS
BEGIN
    -- Truncate the Employee_Hierarchy table
    TRUNCATE TABLE Employee_Hierarchy;

    -- Common Table Expression (CTE) to generate the hierarchy
    WITH EmployeeCTE AS (
        -- Employees who do not report to anyone
        SELECT 
            EMPLOYEEID,
            REPORTINGTO,
            EMAILID,
            CASE 
                WHEN CHARINDEX('.', EMAILID) > 0 THEN LEFT(EMAILID, CHARINDEX('.', EMAILID) - 1)
                ELSE EMAILID
            END AS FIRSTNAME,
            CASE 
                WHEN CHARINDEX('.', EMAILID) > 0 AND CHARINDEX('@', SUBSTRING(EMAILID, CHARINDEX('.', EMAILID) + 1, LEN(EMAILID))) > 0 THEN 
                    LEFT(SUBSTRING(EMAILID, CHARINDEX('.', EMAILID) + 1, LEN(EMAILID)), 
                         CHARINDEX('@', SUBSTRING(EMAILID, CHARINDEX('.', EMAILID) + 1, LEN(EMAILID))) - 1)
                ELSE ''
            END AS LASTNAME,
            1 AS LEVEL
        FROM 
            EMPLOYEE_MASTER
        WHERE 
            REPORTINGTO IS NULL
        
        UNION ALL
        
        -- Recursive part: Employees who report to others
        SELECT 
            e.EMPLOYEEID,
            e.REPORTINGTO,
            e.EMAILID,
            CASE 
                WHEN CHARINDEX('.', e.EMAILID) > 0 THEN LEFT(e.EMAILID, CHARINDEX('.', e.EMAILID) - 1)
                ELSE e.EMAILID
            END AS FIRSTNAME,
            CASE 
                WHEN CHARINDEX('.', e.EMAILID) > 0 AND CHARINDEX('@', SUBSTRING(e.EMAILID, CHARINDEX('.', e.EMAILID) + 1, LEN(e.EMAILID))) > 0 THEN 
                    LEFT(SUBSTRING(e.EMAILID, CHARINDEX('.', e.EMAILID) + 1, LEN(e.EMAILID)), 
                         CHARINDEX('@', SUBSTRING(e.EMAILID, CHARINDEX('.', e.EMAILID) + 1, LEN(e.EMAILID))) - 1)
                ELSE ''
            END AS LASTNAME,
            ec.LEVEL + 1
        FROM 
            EMPLOYEE_MASTER e
        INNER JOIN 
            EmployeeCTE ec ON e.REPORTINGTO = ec.EMPLOYEEID
    )

    -- Insert the generated hierarchy into Employee_Hierarchy table
    INSERT INTO Employee_Hierarchy (EMPLOYEEID, REPORTINGTO, EMAILID, LEVEL, FIRSTNAME, LASTNAME)
    SELECT 
        EMPLOYEEID,
        REPORTINGTO,
        EMAILID,
        LEVEL,
        FIRSTNAME,
        LASTNAME
    FROM 
        EmployeeCTE

END;

-- Execute the stored procedure
EXEC SP_hierarchyF;

-- Check the results
SELECT * FROM Employee_Hierarchy ORDER BY LEVEL, REPORTINGTO;