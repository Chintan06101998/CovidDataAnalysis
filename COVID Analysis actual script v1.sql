select * from CovidAnalysis..CovidDeaths
order by 3,4

select * from CovidAnalysis..CovidVaccinations
order by 3,4   -- based on three four colum

-- Data we are going to use
SELECT location, date, total_cases, new_cases, total_deaths, population from CovidAnalysis..CovidDeaths order by 1

-- Looking at total cases vs Total Deaths
-- shows  likehood of dying if you contract coid in your country
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage  from CovidAnalysis..CovidDeaths
where location = 'India' and continent is not null  -- based on city
order by 1,2

-- Looking at total cases vs populations
-- show what percentage of populaton got covid
SELECT location, date, total_cases, new_cases, population, (total_cases/population)*100 as casePercentage  from CovidAnalysis..CovidDeaths
where location = 'India' and continent is not null  -- based on city
order by 1,2

-- Looking at countries with highest infection rate compared to population
SELECT Location,Population, MAX(total_cases) as HighestInfection, Max(total_cases/population)*100 as PercentagePopulationInfected  from CovidAnalysis..CovidDeaths
where continent is not null
Group by Location, Population
order by PercentagePopulationInfected DESC


-- Countries with highest Death per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathsCount from CovidAnalysis..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathsCount DESC

-- By continent
-- showing continent with highest death count

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathsCount from CovidAnalysis..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathsCount DESC

-- Global Numbers
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths AS int)) as total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 as DeathPercentage  
from CovidAnalysis..CovidDeaths
WHERE continent is not null
GROUP BY date
order by 1,2

-- Word cases
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths AS int)) as total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 as DeathPercentage  
from CovidAnalysis..CovidDeaths
WHERE continent is not null
order by 1,2

SELECT * 
FROM CovidAnalysis..CovidDeaths

-- We can do based on ISO_CODE also
SELECT * 
FROM CovidAnalysis..CovidDeaths dea
JOIN CovidAnalysis..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- Total Population vs vaccinatio per day
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopeVaccinated
FROM CovidAnalysis..CovidDeaths dea
JOIN CovidAnalysis..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3
                     
-- USE CTE
-- Population vs vaccination as per location
-- How many people got vaccination as per location using CTE

WITH popvsvac (continent, location, date, population, new_vaccinations,rollingPeopeVaccinated) as 

(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rollingPeopeVaccinated
FROM CovidAnalysis..CovidDeaths dea
JOIN CovidAnalysis..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null)
SELECT *, (rollingPeopeVaccinated/population)*100 
FROM popvsvac


-- TEMP TABLE
DROP TABLE if exists #PercentPopulalationVaccinated
CREATE TABLE #PercentPopulalationVaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopeVaccinated numeric
)
INSERT INTO #PercentPopulalationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rollingPeopeVaccinated
FROM CovidAnalysis..CovidDeaths dea
JOIN CovidAnalysis..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
SELECT *, (rollingPeopeVaccinated/population)*100 
FROM #PercentPopulalationVaccinated



-- Create a VIEW to store the data for later visualization


CREATE VIEW percentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rollingPeopeVaccinated
FROM CovidAnalysis..CovidDeaths dea
JOIN CovidAnalysis..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

-- dropping view
DROP VIEW if exists percentPopulationVaccinated 

SELECT * FROM percentPopulationVaccinated