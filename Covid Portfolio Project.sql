Select *
From PortfolioProject..['Covid Deaths$']
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..['Covid Vaccinations$']
--order by 3,4

-- Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['Covid Deaths$']
order by 1,2

-- Total Cases VS Total Deaths
-- Shows likelihood of dying if you contract COVID-19 in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..['Covid Deaths$']
Where location like '%enya%'
order by 1,2


-- Total Cases VS Population
-- Shows what percentage of population got COVID-19

Select Location, date, population, total_cases, (total_cases/population)*100 as Infection_Rate 
From PortfolioProject..['Covid Deaths$']
--Where location like '%enya%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as Infection_Rate 
From PortfolioProject..['Covid Deaths$']
--Where location like '%enya%'
Group by Location, population
order by Infection_Rate desc


-- Showing Countries with Highest Death Count By Location

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid Deaths$']
--Where location like '%enya%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- Highest Death Count By Continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid Deaths$']
--Where location like '%enya%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL STATISTICS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
From PortfolioProject..['Covid Deaths$']
-- Where location like '%enya%'
Where continent is not null
Group by date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
From PortfolioProject..['Covid Deaths$']
-- Where location like '%enya%'
Where continent is not null
--Group by date
order by 1,2



-- Total Population VS Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['Covid Vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['Covid Vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac



-- TEMP TABLE

DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['Covid Vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentagePopulationVaccinated


-- Creating View to store data for visualizations

CREATE VIEW PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['Covid Vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3

Select *
From PercentagePopulationVaccinated