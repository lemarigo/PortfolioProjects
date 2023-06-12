-- Covid dataset - Data Exploration

SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in Brazil

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%brazil%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%brazil%'
ORDER BY 1,2

-- Looking at all Countries

SELECT location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
FROM PortfolioProject..CovidDeaths
-- Where location like '%brazil%'
ORDER BY 1,2


-- What country has the highest infection rate compared to Population?

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CasesPercentage
FROM PortfolioProject..CovidDeaths
-- Where location like '%brazil%'
Group by location, population
ORDER BY CasesPercentage desc

-- Showing countries with highest death count per Population
-- By querying this it is identified that we also have continents and the total world population as a row in the dataset which double counts with countries
-- These rows will be filtered out

SELECT location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- Where location like '%brazil%'
Where continent is not null
Group by location
ORDER BY TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death counts per population

SELECT continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- Where location like '%brazil%'
Where continent is not null
Group by continent
ORDER BY TotalDeathCount desc

-- Another way of looking to continents using location column which is more accurate

SELECT location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- Where location like '%brazil%'
Where continent is null
Group by location
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as bigint)) as TotalDeaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
-- Where location like '%brazil%'
Where continent is not null
Group by date
ORDER BY 1,2

-- GLOBAL Summary

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as bigint)) as TotalDeaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
-- Where location like '%brazil%'
Where continent is not null
-- Group by date
ORDER BY 1,2


-- Exploring table Vaccinations

Select *
From PortfolioProject..CovidVaccinations


-- Join tables

Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,
dea.date) as VaccinationRollingCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, VaccinationRollingCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,
dea.date) as VaccinationRollingCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3
)
Select *, (VaccinationRollingCount/population)*100
From PopvsVac


-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
VaccinationRollingCount numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,
dea.date) as VaccinationRollingCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3

Select *, (VaccinationRollingCount/population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,
dea.date) as VaccinationRollingCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3


-- This view will be used for visualizations and dashboards

Select *
From PercentPopulationVaccinated
