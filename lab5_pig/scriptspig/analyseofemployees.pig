-- Chargement des données
Employees = LOAD '/input/employees.txt' USING PigStorage(',') 
                AS (ID:chararray, Nom:chararray, Genre:chararray, Salaire:chararray, depno:chararray, Region:chararray);
                    
-- Chargez les départements
Departments = LOAD '/input/department.txt' USING PigStorage(',') AS (depno:int, name:chararray);


1-- Average salary per department
EmpByDept = GROUP Employees BY depno;
AvgSalary = FOREACH EmpByDept GENERATE group AS depno, AVG(Employees.Salaire) AS average_salary;

-- Jointure pour afficher le nom
AvgSalaryNames = JOIN AvgSalary BY depno, Departments BY depno;
FinalAvgSalary = FOREACH AvgSalaryNames GENERATE Departments::name, AvgSalary::average_salary;

DUMP FinalAvgSalary;


2-- Count employees per department
EmpByDeptCount = GROUP CleanedEmployees BY depno;
CountByDept = FOREACH EmpByDeptCount GENERATE 
              group AS depno, 
              COUNT(CleanedEmployees) AS employee_count;
-- Jointure avec le nom du département
CountByDeptNames = JOIN CountByDept BY depno, Departments BY depno;
FinalCount = FOREACH CountByDeptNames GENERATE Departments::name, CountByDept::employee_count;
DUMP FinalCount;

3-- Join employees with departments to list employees with their department names
ListEmpDept = FOREACH JoinedEmpDept GENERATE 
                  Employees::Nom, 
                  Employees::Genre AS Genre, 
                  Departments::name AS Department_Name;

DUMP ListEmpDept;

4-- Employees with salary > 60000
HighSalary = FILTER Employees BY Salaire > 60000;
DUMP HighSalary;

5-- Depts with most employes
DeptWithMaxSalary = FOREACH HighestPaidDept GENERATE Departments::name, HighestPaidEmp::CleanedEmployees::Salaire AS Salaire;
DUMP DeptWithMaxSalary;

6-- Departments with no employees 
DeptLeftJoin = JOIN Departments BY depno LEFT OUTER, Employees BY depno;
DeptWithoutEmp = FILTER DeptLeftJoin BY Employees::ID IS NULL;
FinalDeptWithoutEmp = FOREACH DeptWithoutEmp GENERATE Departments::name;
DUMP FinalDeptWithoutEmp;

7-- Total number of employees
TotalEmp = GROUP Employees ALL;
TotalCount = FOREACH TotalEmp GENERATE COUNT(Employees) AS Total_Employees;
DUMP TotalCount;


8-- employees in Paris
EmpParis = FILTER Employees BY Region MATCHES 'Paris';
DUMP EmpParis;

9-- Total salary per city
EmpByCity = GROUP Employees BY Region;
TotalSalaryCity = FOREACH EmpByCity GENERATE 
                  group AS City, 
                  SUM(Employees.Salaire) AS Total_Salary;
DUMP TotalSalaryCity;

10-- Departments with female employees
EmpWomen = FILTER CleanedEmployees BY Genre == 'Female';
WomenDeptProj = FOREACH EmpWomen GENERATE depno;
WomenDept = DISTINCT WomenDeptProj;
WomenDeptNames = JOIN WomenDept BY depno, Departments BY depno;
FinalWomenDept = FOREACH WomenDeptNames GENERATE Departments::name;
##enregistrer sous HDFS
STORE FinalWomenDept INTO '/pigout/employes_femmes';
