select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select *
from PortfolioProject..CovidVaccinations
order by 3,4

-- select data that we are going to be using

-- shows the likelihood of dying if you contract covid in your country
select location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
where location = 'India'
order by 1,2

-- looking at the total cases vs population
-- shows what percentage of population has got covid
select location, date, population, total_cases, (total_cases/population)*100 as caseperpopulation
from PortfolioProject..CovidDeaths
where location = 'United States'
order by 1,2

-- looking at countries with heightest infection rate compared to population
select location, population, max(total_cases) as HeighestInfectionCount, max((total_cases/population)*100) as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
group by location, population
order by PercentagePopulationInfected desc


-- LET'S BREAK THINGS DOWN BY CONTINENT


--  Showing countries with heighest death count per population

-- Showing the continents with the heighest death counts

select continent, max(cast(total_deaths as int)) as CovidDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by CovidDeathCount desc


-- GLOBAL NUMBERS

-- Daily New cases vs New deaths percentage
select date, sum(new_cases) as Total_case, sum(cast(new_deaths as int)) as Total_deaths, (sum(cast(new_deaths as int)))/(sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- New Death Percentage (global numbers)
select sum(new_cases) as Total_case, sum(cast(new_deaths as int)) as Total_deaths, (sum(cast(new_deaths as int)))/(sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--JOIN TABLES
--pseudo code: 
-- inner join on location
-- table covid deaths & vaccines
-- use aliases

--looking at total vaccinations vs population
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac 
	on vac.location = dea.location
	and vac.date = dea.date
where dea.continent is not null
order by 2,3


-- FINDING NEW VACCINATIONS PER DAY

--creating CTE to find the total number of population vaccinated

with CTE_popvsvac (continent, location, date, population, new_vaccinations, total_vac_per_day )
as
(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as total_vac_per_day
	from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac 
		on vac.location = dea.location
		and vac.date = dea.date
	where dea.continent is not null
)
select *, (total_vac_per_day/population)* 100 as total_pop_vaccinated
from CTE_popvsvac



-- TEMP TAB

drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
Continent  nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccination numeric,
total_vac_per_day numeric
)

insert into #PercentagePopulationVaccinated
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as total_vac_per_day
	from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac 
		on vac.location = dea.location
		and vac.date = dea.date
	where dea.continent is not null

select *, (total_vac_per_day/population)* 100 as total_pop_vaccinated
from #PercentagePopulationVaccinated



-- CREATING VIEW TO STORE DATA FRO LATER VISUALIZATION

create view PercentagePopulationVaccinated as
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as total_vac_per_day
	from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac 
		on vac.location = dea.location
		and vac.date = dea.date
	where dea.continent is not null


-- WORKTABLE FOR TABLEAU
select * 
from PercentagePopulationVaccinated