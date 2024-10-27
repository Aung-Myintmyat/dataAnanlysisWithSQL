UPDATE coviddeaths
SET date = STR_TO_DATE(date, '%m/%d/%Y');

UPDATE covidvaccinated
SET date = STR_TO_DATE(date, '%m/%d/%Y');

SELECT * FROM coviddeaths
-- WHERE continent IS NOT NULL
ORDER BY 3,5
;

-- SELECT * FROM covidvaccinated
-- ORDER BY 3,5
-- ;

SELECT location , date , total_cases , new_cases , total_deaths , population
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1 ,5
;

-- TOTAL CASES VS TOTAL DEATHS
-- Show likehood of dying if you contract covid in your country
SELECT location, 
       date, 
       total_cases, 
       total_deaths,  
       ((total_deaths / total_cases)*100)AS DeathPercentage
FROM coviddeaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1,2 ;

-- Looking at Total Cases vs Population

SELECT location, 
       date, 
       total_cases, 
       total_deaths,  
       ((total_deaths / total_cases)*100)AS death_rate
FROM coviddeaths
WHERE location LIKE '%Myanmar%'
ORDER BY 1,2 ;

-- Looking at Total Cases vs Population
-- Show What percentage of population got COvid
SELECT location, 
       date, 
		population,
       total_cases, 
       (( total_cases/population)*100)AS PercentPopulationInfected
FROM coviddeaths
-- WHERE location LIKE '%states%'
ORDER BY 1,2 ;

-- Looking at Countries with Hightest Infection Rate compared to Population
SELECT location, 
		population,
       MAX(total_cases) AS HighestInfectionCount, 
       (MAX(( total_cases/population))*100)AS PercentPopulationInfected
FROM coviddeaths
-- WHERE location LIKE '%states%'
GROUP BY population,location
ORDER BY PercentPopulationInfected DESC;

-- Showing Countries With Hightest Death Count Per Popution
SELECT location, 
       MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM coviddeaths
WHERE continent != ''  -- Filtering out blank values
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Let Break Things Down By Continent

-- Showing continents with the highest death count per population
SELECT continent,
       MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM coviddeaths
WHERE continent != ''  -- Filtering out blank values
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- GLOBAL NUMBER

SELECT SUM(new_cases) as total_cases ,SUM(CAST(new_deaths AS SIGNED)) as total_deaths, SUM(CAST(new_deaths AS SIGNED))/SUM(new_cases)*100 AS DeathPercentage
FROM coviddeaths
-- WHERE location LIKE '%states%'
WHERE continent != ''  -- Filtering out blank values
-- GROUP BY date
ORDER BY 1,2 ;

-- Looking at Total Population vs Vaccinations

SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations, SIGNED))OVER(Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM coviddeaths dea
JOIN covidvaccinated vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent != ''  -- Filtering out blank values
ORDER BY 2,3;

-- Use CTE
with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as(
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations, SIGNED))OVER(Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM coviddeaths dea
JOIN covidvaccinated vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent != ''  -- Filtering out blank values
-- ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopvsVac;


-- Temp Table

DROP Table if exists PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated (
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Date DATETIME,
    Population DECIMAL(15, 2),
    New_vaccinations DECIMAL(15, 2),
    RollingPeopleVaccinated DECIMAL(15, 2)
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, 
       dea.location, 
       dea.date, 
       dea.population, 
       vac.new_vaccinations,
       SUM(CONVERT(COALESCE(vac.new_vaccinations, 0), SIGNED)) 
           OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinated vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE vac.new_vaccinations != '';  -- Exclude empty strings
-- WHERE dea.continent != '';


SELECT *,(RollingPeopleVaccinated/population)*100
FROM PercentPopulationVaccinated;

-- Create View To store data for later visualizations 

Create View PercentPopulationVaccinated as
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations, SIGNED))OVER(Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM coviddeaths dea
JOIN covidvaccinated vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent != ''  -- Filtering out blank values
-- ORDER BY 2,3
