Select * 
From coviddeaths
order by 3,4;

-- Select * 
-- From covidvaccinations
-- order by 3,4;

Select Location, date, total_cases, new_cases, total_deaths, population
From coviddeaths;

-- Looking at Total Cases vs Total Deaths 
-- Shows the likelihood of dying If you contract Covid-19 in France

Select location, date, total_cases, total_deaths,
	Case 
			When total_deaths = 0 OR total_cases = 0 Then 0
			Else (total_deaths::float / total_cases) * 100
	End AS death_percentage		
From coviddeaths
Where location = 'France'
order by 1,2;

--Looking at Total Cases vs Population
--Shows the percentage of population got Covid

Select location, date, total_cases, population, (total_cases::float/population) * 100 as CasesPercentage
From coviddeaths
Where location = 'France'
order by 1,2;

--Looking at the Countries with Highest Infection Rate compared to Population

SELECT location, MAX(total_cases) AS max_total_cases, population, 
MAX((total_cases::float / population)) * 100 AS CasesPercentage
FROM coviddeaths
GROUP BY location, population
ORDER BY CasesPercentage desc;

--Showing Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) AS max_total_deaths
FROM coviddeaths
WHERE continent is not null
GROUP BY location
ORDER BY max_total_deaths desc;


-- Looking down by Continent

SELECT location, MAX(total_deaths) AS max_total_deaths
FROM coviddeaths
WHERE continent is null
GROUP BY location
ORDER BY max_total_deaths desc;

-- Global Death Percentage

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as death_percentage
From coviddeaths
where continent is not null 
order by 1,2

-- Looking at Total Population vs Vaccinations

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cv.new_vaccinations) OVER (Partition by cd.location Order by cd.location, cd.date) as Rolling_People_Vaccinated
From coviddeaths cd
Join covidvaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
Where cd.continent is not null 
ORDER BY 2,3

--Using CTE to perform Calculation on Partition to Show Percentage of Population that has recieved at least one Covid Vaccine
	
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cv.new_vaccinations) OVER (Partition by cd.Location Order by cd.location, cd.Date) as Rolling_People_Vaccinated
From coviddeaths cd
Join covidvaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
)
Select *, (Rolling_People_Vaccinated/Population)*100
From PopvsVac

--Using Temp Table to perform Calculation on Partition to Show Percentage of Population that has recieved at least one Covid Vaccine

-- Drop the table if it exists
DROP TABLE IF EXISTS PercentPopulationVaccinated;

-- Create the temporary table
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Date TIMESTAMP,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    Rolling_People_Vaccinated NUMERIC
);

-- Insert data into the temporary table
INSERT INTO PercentPopulationVaccinated (Continent, Location, Date, Population, New_vaccinations, Rolling_People_Vaccinated)
SELECT 
    cd.continent, 
    cd.location, 
    cd.date, 
    cd.population, 
    cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date) AS Rolling_People_Vaccinated
FROM 
    coviddeaths cd
JOIN 
    covidvaccinations cv
    ON cd.location = cv.location
    AND cd.date = cv.date;

-- Select data from the temporary table with the calculated percentage
SELECT 
    *, 
    (Rolling_People_Vaccinated / Population) * 100 AS Vaccination_Percentage
FROM 
    PercentPopulationVaccinated;


--Creating View to store data for Visualization

Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cv.new_vaccinations) OVER (Partition by cd.location Order by cd.location, cd.date) as Rolling_People_Vaccinated
From coviddeaths cd
Join covidvaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
Where cd.continent is not null 
ORDER BY 2,3

