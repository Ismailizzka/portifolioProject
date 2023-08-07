
-- review the data
select * 
from portifolioProject..CovidDeaths
order by 3, 4

select * 
from portifolioProject..CovidVaccinations
order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population
from portifolioProject..CovidDeaths
order by 1, 2

-- compare total deaths to the total cases

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from portifolioProject..CovidDeaths
order by 1, 2

-- looking for countries with the highest infection rate compared to the poplation 

select location, population, max(total_cases) as HighestInfectedCount, max((total_cases/population))*100 as infectedPopulationPercentage
from portifolioProject..CovidDeaths
Group by location, population
order by infectedPopulationPercentage desc


-- showing the countries with the highest death count per population

select location, max(cast(total_deaths as int)) as CountriesWithMostDeath
from portifolioProject..CovidDeaths
where total_deaths is not null and continent is not null
group by location
order by CountriesWithMostDeath desc
offset 0 rows
fetch next 10 rows only;


--GLOBAL NUMBERS 

select date, sum(new_cases) as totalNewCases, sum(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int))/NULLIF(sum(new_cases),0)*100 as deathPercentage
from portifolioProject..CovidDeaths
group by date 
order by date

-- summary of global cases and deaths

select sum(new_cases) as totalNewCases, sum(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int))/NULLIF(sum(new_cases),0)*100 as deathPercentage
from portifolioProject..CovidDeaths


-- JOINIG DIFFERENT TABLES 

-- looking at total population vs vaccination 

select Dea.location, Dea.date, Dea.continent, Dea.population, Vac.new_vaccinations,
sum(cast(Vac.new_vaccinations as int)) over (partition by Dea.location order by Dea.location, Dea.date) as rollingPeopleVaccinated
from portifolioProject..CovidDeaths Dea
join portifolioProject..CovidVaccinations Vac
 on Dea.location = Vac.location
 and Dea.date = Vac.date 
 where Dea.continent is not null
 --group by Dea.continent, Dea.location, Dea.date,  Dea.population
 order by 1, 2

-- vacinated percentage of the population

-- use CTE
with popvsVac (location, date, continent, population, new_vacinations, RollingPeopleVaccinated)
as(
select Dea.location, Dea.date, Dea.continent, Dea.population, Vac.new_vaccinations,
sum(cast(Vac.new_vaccinations as int)) over (partition by Dea.location order by Dea.location, Dea.date) as rollingPeopleVaccinated
from portifolioProject..CovidDeaths Dea
join portifolioProject..CovidVaccinations Vac
 on Dea.location = Vac.location
 and Dea.date = Vac.date 
 where Dea.continent is not null
 --order by 1, 2
 )
select *,(RollingPeopleVaccinated/population)*100 as vaccPerc
from popvsVac



-- TEMP table

drop table if exists #PercentPopulationVacinated
Create Table #PercentPopulationVacinated 
(
Location nvarchar(255),
Date datetime,
Continent nvarchar(255),
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVacinated
select Dea.location, Dea.date, Dea.continent, Dea.population, Vac.new_vaccinations,
sum(cast(Vac.new_vaccinations as int)) over (partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
from portifolioProject..CovidDeaths Dea
join portifolioProject..CovidVaccinations Vac
 on Dea.location = Vac.location
 and Dea.date = Vac.date 
 where Dea.continent is not null
 --order by 1, 2

 select *, (RollingPeopleVaccinated/Population)*100
 from #PercentPopulationVacinated
  



 -- create VIEW to store the data for later visualization


 use portifolioProject
 Go
 Create View PercentagePopulationVaccinated0001 as
 select Dea.location, Dea.date, Dea.continent, Dea.population, Vac.new_vaccinations,
sum(cast(Vac.new_vaccinations as int)) over (partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
from portifolioProject..CovidDeaths Dea
join portifolioProject..CovidVaccinations Vac
 on Dea.location = Vac.location
 and Dea.date = Vac.date 
 where Dea.continent is not null
 --order by 1, 2