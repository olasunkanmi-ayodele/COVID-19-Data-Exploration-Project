/* COVID 19 DATA EXPLORATION

Skills Used: Joins, CTE's, Temp Tables, Window Functions, Aggragate Functions, Creating Views, Converting Datatypes 

*/

Select *
from CovidPortfolioProject..CovidDeaths
order by 3,4

Select *
from CovidPortfolioProject..CovidVaccinations
order by 3,4

--Select Data we are going to be using

Select location, new_date, total_cases, new_cases, total_deaths, population
from CovidPortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--alter table to change data type

alter table CovidPortfolioProject..CovidDeaths alter column total_deaths float NULL
alter table CovidPortfolioProject..CovidDeaths alter column total_cases float NULL

--Looking at Total Cases Vs Total Deaths
--Shows the likelihood of dying if you contract the covid in your country

Select location, new_date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS death_percentage
from CovidPortfolioProject..CovidDeaths
where location like '%nigeria%'
order by 1,2 

--Looking at total cases vs Population
--Shows what percentage of population got covid

Select location, new_date, total_cases, population, (total_cases / population)*100 AS percent_population_infected
from CovidPortfolioProject..CovidDeaths
where location like '%nigeria%'
and continent is not null
order by 1,2 

--Looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases / population))*100 AS percent_population_infected
From CovidPortfolioProject..CovidDeaths 
--where location like '%nigeria%'
group by location, population
order by percent_population_infected desc

--Showing countries with the highest death count per population

Select location, MAX(cast(total_deaths as int)) AS total_death_count
From CovidPortfolioProject..CovidDeaths 
--where location like '%states%' 
where continent is not null
group by location
order by total_death_count desc

--LETS BREAK THINGS DOWN BY CONTINENT
--Showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) AS total_death_count
from CovidPortfolioProject..CovidDeaths 
--where location like '%states%' 
where continent is not null
group by continent
order by total_death_count desc

--Global Numbers

Select SUM(CAST(new_cases AS INT)) as total_cases,
       SUM(CAST(new_deaths AS INT)) as total_deaths,
       CASE WHEN SUM(new_cases) <> 0 THEN (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100 ELSE 0 END AS death_percentage
from CovidPortfolioProject..CovidDeaths
where continent IS NOT NULL
--GROUP BY new_date
order by 1,2

--looking at total population vs vacinations

Select dea.continent,
       dea.location,
       dea.new_date,
       dea.population,
       vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location order by dea.location, dea.new_date) as rolling_people_vaccinated
from CovidPortfolioProject..CovidDeaths dea
join CovidPortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
    and dea.new_date = vac.date 
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (continent, location, new_date, population, new_vaccinations, rolling_people_vaccinated)
as (
Select dea.continent,
       dea.location,
       dea.new_date,
       dea.population,
       vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location order by dea.location, dea.new_date) as rolling_people_vaccinated
from CovidPortfolioProject..CovidDeaths dea
join CovidPortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    and dea.new_date = vac.date 
where dea.continent is not null
--ORDER BY 2,3
)
select *, (rolling_people_vaccinated/population)*100
from PopvsVac

--USE TEMP TABLE TO PERFORM PARTITION BY IN PREVIOUS QUERY

drop table if exists #percent_population_vaccinated 
Create Table #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
new_date datetime, 
population numeric, 
new_vaccinations numeric, 
rolling_people_vaccinated numeric
)

Insert into #percent_population_vaccinated
Select dea.continent,
       dea.location,
       dea.new_date,
       dea.population,
       vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location order by dea.location, dea.new_date) as rolling_people_vaccinated
from CovidPortfolioProject..CovidDeaths dea
join CovidPortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
    and dea.new_date = vac.date  
--where dea.continent is not null
--order by 2,3

select *, (rolling_people_vaccinated/population)*100
from #percent_population_vaccinated  

       

