SELECT location,
	date,
    new_cases,
    new_deaths,
    hosp_patients,
    new_cases_per_million,
    new_deaths_per_million,
    hosp_patients_per_million
 FROM covid
 WHERE continent > ' '
 ORDER BY 1, 2;

DROP VIEW IF EXISTS main_measures;

CREATE VIEW main_measures AS 
SELECT location,
	date,
    new_cases,
    new_deaths,
    hosp_patients,
    new_cases_per_million,
    new_deaths_per_million,
    hosp_patients_per_million
 FROM covid
 WHERE continent > ' '
 ORDER BY 1, 2;

SELECT location,
	date,
	new_cases,
    new_deaths,
    hosp_patients,
    new_cases_per_million,
    new_deaths_per_million,
    hosp_patients_per_million
 FROM covid
 WHERE location = 'World'
 ORDER BY 1 , 2;
 
 SELECT location,
	date,
	new_cases,
    new_cases_per_million
 FROM covid
 WHERE location = 'France'
	AND date BETWEEN '2022-01-18' AND '2022-01-25'
 ORDER BY 1 , 2;