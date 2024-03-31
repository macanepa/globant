-- MySQL
/*
Number of employees hired for each job and department in 2021 divided by quarter.
The table must be ordered alphabetically by department and job.
*/
SELECT 
    d.department, 
    j.job, 
    SUM(CASE WHEN MONTH(h.datetime) BETWEEN 1 AND 3 THEN 1 ELSE 0 END) AS Q1,
    SUM(CASE WHEN MONTH(h.datetime) BETWEEN 4 AND 6 THEN 1 ELSE 0 END) AS Q2,
    SUM(CASE WHEN MONTH(h.datetime) BETWEEN 7 AND 9 THEN 1 ELSE 0 END) AS Q3,
    SUM(CASE WHEN MONTH(h.datetime) BETWEEN 10 AND 12 THEN 1 ELSE 0 END) AS Q4
FROM globant.hired_employees h
LEFT JOIN globant.departments d ON h.department_id = d.id
LEFT JOIN globant.jobs j ON h.job_id = j.id
WHERE YEAR(h.datetime) = 2021
GROUP BY d.department, j.job
ORDER BY d.department, j.job;



/*
List of ids, name and number of employees hired of each department that hired more
employees than the mean of employees hired in 2021 for all the departments, ordered
by the number of employees hired (descending).
*/
WITH new_hires_by_department AS (
	SELECT h.department_id, COUNT(0) AS hired
	FROM globant.hired_employees h
	WHERE YEAR (h.datetime) = 2021
	GROUP BY h.department_id 
)
SELECT d.id, d.department, hired FROM new_hires_by_department
JOIN globant.departments d
    ON (d.id = new_hires_by_department.department_id)
WHERE (SELECT AVG(hired) FROM new_hires_by_department) <= hired
GROUP BY new_hires_by_department.department_id, d.department
ORDER BY hired DESC;