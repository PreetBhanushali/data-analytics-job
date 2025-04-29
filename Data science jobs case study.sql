--You're a Compensation analyst employed by a multinational corporation. 
-- Your Assignment is to Pinpoint Countries who 
--give work fully remotely, for the title 'managers’ Paying salaries 
-- Exceeding $90,000 USD

SELECT
	DISTINCT company_location
FROM
	salaries
WHERE job_title like '%manager%'
AND remote_ratio = 100
AND salary_in_usd > 90000;


--AS a remote work advocate Working for a progressive HR tech startup who
--  place their freshers’ clients IN large tech firms. you're tasked WITH
-- dentifying top 5 Country Having greatest count of large (company size)
--  number of companies.

SELECT
	company_location
FROM
	salaries
WHERE company_size = 'L'
AND experience_level = 'EN'
GROUP by company_location
ORDER by count(work_year) DESC
LIMIT 5;

--Your objective is to calculate the percentage of employees. Who enjoy fully 
-- remote roles WITH salaries Exceeding $100,000 USD, Shedding light ON the 
-- attractiveness of high-paying remote positions IN today's job market

SELECT
	(count(work_year)*100/(SELECT count(work_year) from salaries))|| '%' as percentage
FROM
	salaries
WHERE remote_ratio = 100
AND salary_in_usd > 100000;


--Your Task is to identify the Locations where entry-level average salaries 
-- exceed the average salary for that job title IN market for entry level, 
-- helping your agency guide candidates towards lucrative opportunities.
WITH cte as(
SELECT
	company_location
	,job_title
	,round(avg(salary) over(PARTITION by job_title),2)as avg_salary
	,(SELECT round(avg(salary),2) FROM salaries as b WHERE experience_level='EN' AND b.company_location=a.company_location AND b.job_title=a.job_title)as avg_en_job_title_sal
FROM
	salaries as a
where experience_level = 'EN')
SELECT DISTINCT company_location
FROM cte
WHERE avg_salary > avg_en_job_title_sal;


--  Your job is to Find out for each job title which. Country pays the 
--  maximum average salary. This helps you to place your candidates IN 
--  those countries.

WITH cte as(
SELECT 
	 job_title
	 ,company_location
	,round(avg(salary),2) as avg_salary
	,dense_rank() OVER(PARTITION by job_title ORDER by avg(salary) desc) as ranking
FROM salaries
GROUP by 1,2)
SELECT job_title,company_location,avg_salary as highest_avg_salary
FROM cte 
WHERE ranking = 1; 

	
-- Your goal is to Pinpoint Locations WHERE the average salary Has consistently Increased
--  over the Past few years (Countries WHERE data is available for 3 years Only(present year 
--  and past two years) providing Insights into Locations experiencing Sustained salary growth.
SELECT company_location 
FROM
(
WITH cte as(
	SELECT t1.company_location,avg_sal_2022,avg_sal_2023 FROM
	(
		SELECT
			a.company_location
			,round(avg(salary),2) as avg_sal_2022
		FROM
			salaries as a
		WHERE work_year = 2022
		GROUP by company_location
		) as t1,
				(
				SELECT
					b.company_location
					,round(avg(salary),2) as avg_sal_2023
				FROM
					salaries as b
				WHERE work_year = 2023
				GROUP by company_location)
				as t2
		WHERE t1.company_location = t2.company_location
)
SELECT
	cte.company_location,avg_sal_2022,avg_sal_2023,avg_sal_2024
FROM
	cte,(
	SELECT company_location,round(avg(salary),2) as avg_sal_2024
	FROM salaries 
	WHERE work_year = 2024
	GROUP by company_location
	) as t4
WHERE cte.company_location=t4.company_location
)
where avg_sal_2022 < avg_sal_2023 
and avg_sal_2023 < avg_sal_2024;



--Your Mission is to Determine the percentage of fully remote work for each experience
--  level IN 2021 and compare it WITH the corresponding figures for 2024, Highlighting any
--  significant Increases or decreases IN remote work Adoption over the years.

SELECT t1.experience_level,remote_percent_in_2021,remote_percent_in_2024
FROM(

	(SELECT
		experience_level
		,round((round(count(work_year),3)*100/(SELECT count(work_year) FROM salaries WHERE work_year=2021)),2) || '%' as remote_percent_in_2021
	FROM
		salaries as t1
	WHERE work_year = 2021
	AND remote_ratio = 100
	GROUP BY experience_level) as t1,

	(SELECT
		experience_level
		,(round(round(count(work_year),3)*100/(SELECT count(work_year) FROM salaries WHERE work_year=2024),2)) || '%' as remote_percent_in_2024
	FROM
		salaries as t2
	WHERE work_year = 2024
	AND remote_ratio = 100
	GROUP BY experience_level) as t2
)WHERE t1.experience_level=t2.experience_level;









