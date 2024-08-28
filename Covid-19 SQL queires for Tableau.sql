--Table 1
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From coviddeaths
where continent is not null 
order by 1,2


--Table 2
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From coviddeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


--Table 3
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases::float/population))*100 as PercentPopulationInfected
From coviddeaths
Group by Location, Population
order by PercentPopulationInfected desc


--For Table 4 I had to fix some issues because when I enter my query I was having issues with highestinfections and percentpopulationinfected columns they were returning null.
-- I had to spot the null values with this query 
SELECT 
    COUNT(*) 
FROM 
    coviddeaths 
WHERE 
    total_cases IS NULL 
    OR population IS NULL;
--Then I change the Null Values to 0
UPDATE coviddeaths
SET total_cases = 0
WHERE total_cases IS NULL;

UPDATE coviddeaths
SET population = 0
WHERE population IS NULL;


--Table 4
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases::float/population))*100 as PercentPopulationInfected
From coviddeaths
Group by Location, Population, date
order by PercentPopulationInfected desc




