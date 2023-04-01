select * from portfolio_project..CovidDeaths$
where continent is not null 
order by 3,4;

--select * from portfolio_project..CovidVaccinations
--order by 3,4;

select location,date,population,total_cases,new_cases,total_deaths,population from portfolio_project..CovidDeaths$
order by 1,2;

ALTER TABLE CovidDeaths$ ALTER COLUMN total_cases float


--Total cases vs Total deaths
--Shows the likelihood if you contradict covid in your country

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercentage from portfolio_project..CovidDeaths$
where location='Asia'
order by 1,2;

--Total cases vs populations
--shows what % of population got covid
select location,population, (total_cases/population)*100 as populationpercentage from portfolio_project..CovidDeaths$
--where location='Asia'
order by 1,2;

--Looking at countries with highest infectionr rate
select location,population,max(total_cases) as MAX_INFECTED_COUNT, max((total_cases/population)*100) as PERCENT_POPULATION_IMPACTED from portfolio_project..CovidDeaths$
--where location='Asia'
GROUP by location,population
order by PERCENT_POPULATION_IMPACTED desc


--Showing the country highest death countper population
select location,max(cast(total_deaths as int)) as MAX_DEATH_COUNT from portfolio_project..CovidDeaths$
--where location='Asia' where continent is not null 
GROUP by location
order by MAX_DEATH_COUNT desc


--Lets bring downs by continent
select continent,max(cast(total_deaths as int)) as MAX_DEATH_COUNT from portfolio_project..CovidDeaths$
--where location='Asia' 
where continent is not null 
GROUP by continent
order by MAX_DEATH_COUNT desc

--Showing a continent with highest death count per population
select continent,max(cast(total_deaths as int)) as MAX_DEATH_COUNT from portfolio_project..CovidDeaths$
--where location='Asia' 
where continent is not null 
GROUP by continent
order by MAX_DEATH_COUNT desc

--Global numbers
select sum(new_cases) as totalcases,sum(new_deaths) as totaldeaths, sum(new_deaths)/sum(total_cases)*100 as deathrate from portfolio_project..CovidDeaths$
where continent is not null 
--group by date
order by 1,2;


--Join the tables

--Looking at total popualtion vs vacciantions
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations )) over(partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated,
--(rolling_people_vaccinated/dea.population) 
from CovidDeaths dea join CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null
order by 2,3;




--USE CTE ( Common Table Expressions )

with PopvsVac (Continent,location,date,population,New_Vaccinations,rolling_people_vaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_Vaccinations as bigint )) over(partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated/dea.population) 
from CovidDeaths dea join CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null
)
select *,(rolling_people_vaccinated/population)*100 from PopvsVac 


--TEMP TABLE

drop table if exists percentpopulationvaccinated
create table percentpopulationvaccinated (Continent nvarchar(255),location nvarchar(255),date datetime,population numeric,New_Vaccinations numeric,rolling_people_vaccinated numeric)
insert into percentpopulationvaccinated
	select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_Vaccinations as bigint )) over(partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated/dea.population) 
from CovidDeaths dea join CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date 
--where dea.continent is not null
select *,(rolling_people_vaccinated/population)*100 from percentpopulationvaccinated


--Create a view to store the data for later visualzations

create view PercentPopVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_Vaccinations as bigint )) over(partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated/dea.population) 
from CovidDeaths dea join CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null

select * from PercentPopVaccinated;


