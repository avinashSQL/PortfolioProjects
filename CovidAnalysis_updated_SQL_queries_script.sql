-- Querying and checking the loaded databases related to Covid Deaths and Covid Vaccinations

select *
from PortfolioProject_covid_updated..CovidDeaths -- Query for checking CovidDeath 
where continent is not null
order by date desc

select *
from PortfolioProject_covid_updated..CovidVaccinations -- Query for checking CovidVaccinations table
where continent is not null
order by 1,2


-- Insights into Total Deaths vs Total Cases
-- Shows the likelihood of dying if you contract COVID in your country
select location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 DeathPercentage
from PortfolioProject_covid_updated..CovidDeaths
where location = 'United States' and continent is not null
order by 1,2

-- (note: DeathPercentage formuala needs to be casted to FLOAT as nvarchar values can not be divided)


-- Insights into Total Cases vs Population
-- Show what percentage of population got COVID
select location, date, population, total_cases, (total_cases/population)*100 covidperpopulation
from PortfolioProject_covid_updated..CovidDeaths
where location = 'India' and continent is not null
order by 1,2 desc

-- Insights into Countries with Heighest Infections Rate compared to Population
-- shows what percent of population had contracted COVID
select location, population, max(total_cases) as HeighestInfectionCount, (max(total_cases)/population)*100 PercentPopulationInfected
from PortfolioProject_covid_updated..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc
------------------------------------------------------------------------------------------------------------------------------------
-- TABLE JOIN SECTION (begins here!) (ADVANCED SQL QUERIES)

-- LET'S BREAK THINGS DOWN BY CONTIENT

-- Insights into continent with Heightest Death Count per Population
-- Shows the total COVID death count for each Continet
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject_covid_updated..CovidDeaths
where continent is not null -- location <> continent
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
select SUM(new_cases) as total_case, SUM(cast(new_deaths as int)) as total_deaths
, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PortfolioProject_covid_updated..CovidDeaths
where continent is not null



-- Looking at Total Population vs Vacciantions
-- Join Tables
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.date, dea.location) as RollingPeopleVaccinated
from PortfolioProject_covid_updated..CovidDeaths dea
join PortfolioProject_covid_updated..CovidVaccinations vac
	on vac.location = dea.location -- tables joined on LOCATION
	and vac.date = dea.date -- tables joined on DATE
where dea.continent is not null
order by 2,3



-- Using CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.date, dea.location) as RollingPeopleVaccinated
from PortfolioProject_covid_updated..CovidDeaths dea
join PortfolioProject_covid_updated..CovidVaccinations vac
	on vac.location = dea.location -- tables joined on LOCATION
	and vac.date = dea.date -- tables joined on DATE
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 as PercentRollingPeopleVaccinated
from PopvsVac


-- TEMP TABLE


drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.date, dea.location) as RollingPeopleVaccinated
from PortfolioProject_covid_updated..CovidDeaths dea
join PortfolioProject_covid_updated..CovidVaccinations vac
	on vac.location = dea.location -- tables joined on LOCATION
	and vac.date = dea.date -- tables joined on DATE
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100 as PercentRollingPeopleVaccinated
from #PercentPopulationVaccinated
-------------------------------------------------------------------------------------------------------------------------------------

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

-- 1. Percentage of population vaccinated
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.date, dea.location) as RollingPeopleVaccinated
from PortfolioProject_covid_updated..CovidDeaths dea
join PortfolioProject_covid_updated..CovidVaccinations vac
	on vac.location = dea.location -- tables joined on LOCATION
	and vac.date = dea.date -- tables joined on DATE
where dea.continent is not null



select *
from PercentPopulationVaccinated