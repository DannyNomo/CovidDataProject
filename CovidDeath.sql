select * from CovidDeaths
select * from CovidVaccinations

--Looking at Total cases vs Total Deaths
--the rate at which one can contract covid on that day in a country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage from CovidDeaths order by 1,2

--Looking at Total Cases vs Population
--the percentage of people infected by COVID
select location,date,population,total_cases,(total_cases/population)*100 as InfectedPeople from CovidDeaths order by 1,2

--Looking at Countries with the highest infection rate
select location,population,max(total_cases) as HighestInfectionCount,Max(total_cases/population)*100 as HighestInfectedPeople from CovidDeaths group by location,population order by HighestInfectedPeople desc

--Looking at Countries with the highest death counts
select location,max(cast (total_deaths as int)) as TotalDeathCount from CovidDeaths where continent is not null  group by location order by TotalDeathCount desc
select location,population,max(total_deaths) as HighestDeathCount,Max(total_deaths/population)*100 as HighestDeathRate from CovidDeaths group by location,population order by HighestDeathRate desc

--Looking at Continents with the highest Death counts
select location,max(cast (total_deaths as int)) as TotalDeathCount from CovidDeaths where continent is null and location not like '%World%' group by location order by TotalDeathCount desc

--Looking st World Statistics
select location,max(cast (total_deaths as int)) as TotalDeathCount from CovidDeaths where continent is null and location like '%World%' group by location order by TotalDeathCount desc

Select date,sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage from CovidDeaths where continent is not null group by date order by 1,2


--Using the vaccination data also
select * from CovidVaccinations order by date,location

--Global Statistics
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations from CovidDeaths dea 
join CovidVaccinations vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
order by 2,3

--Lookin at Canada's  vaccination numbers
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations from CovidDeaths dea 
join CovidVaccinations vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null and dea.location like '%Canada%'
order by 2,3

--Total Population vs Vaccinations
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as PeopleVaccinatedAsc
from CovidDeaths dea join CovidVaccinations vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
order by 2,3

--Using the alias to get the vaccination rate/percentage. Either I use a CTE or Temp Table
--Using CTE 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinatedAsc)
as
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as PeopleVaccinatedAsc
from CovidDeaths dea join CovidVaccinations vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (PeopleVaccinatedAsc/population)*100 from PopvsVac

--Using Temp Table
Drop Table if exists #PercentPeopleVaccinated 
Create table #PercentPeopleVaccinated (Continent nvarchar(255), Location nvarchar(255), date datetime, population numeric, new_Vaccinations numeric, PeopleVaccinatedAsc numeric)
Insert into #PercentPeopleVaccinated 
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as PeopleVaccinatedAsc
from CovidDeaths dea join CovidVaccinations vac on dea.location=vac.location and dea.date=vac.date
--where dea.continent is not null 
--order by 2,3
Select *, (PeopleVaccinatedAsc/population)*100 as VacRate from #PercentPeopleVaccinated


--Creating Views
create view PopulationVaccinatedPercemtage as
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as PeopleVaccinatedAsc
from CovidDeaths dea join CovidVaccinations vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
--order by 2,3

select * from PopulationVaccinatedPercemtage
