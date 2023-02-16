Project--------------------------------------------------------------------------------------------------------------------


SELECT * 
FROM [Portfolioproject].[dbo].[CovidDeaths]
where continent is not null
order by 3,4


SELECT * 
FROM [Portfolioproject].[dbo].[Covidvaccinations]
Order by 3,4

SELECT Location, date,  total_cases, new_cases,total_deaths,population
FROM [Portfolioproject].[dbo].['CovidDeaths']
order by 1,2


--Looking at Total Cases vs Total Death
-- Shows the Likelyhood of dying if u contarct Covid in your country
SELECT Location, date,  total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolioproject].[dbo].['CovidDeaths']
WHERE Location like '%Pak%'
order by 1,2

--Looking at Total Cases vs Population 
-- Shows what Percentage of Population Dying Through Covid

SELECT Location, population, Max(total_cases) AS HighestInfectioncount,  Max((total_cases/population))*100 AS PercentagePopulationInfected
FROM [Portfolioproject].[dbo].[CovidDeaths]
--WHERE Location like '%AFG%'
order by 1,2

--Looking at Countries with Highest Numbers of Cases/Infection Rate Compared to Population 

SELECT Location, population, Max(total_cases) AS HighestInfectioncount,  Max((total_cases/population))*100 AS PercentagePopulationInfected
FROM [Portfolioproject].[dbo].[CovidDeaths]
--WHERE Location like '%AFG%'
Group by Location, population
order by PercentagePopulationInfected desc
 

 --Looking at Countries with Highest Numbers of Deaths Rate Compared to Population 

 SELECT Location, population, Max(total_deaths) AS HighestDeathcount,  Max((total_deaths/population))*100 AS PercentagePopulationDeath
FROM [Portfolioproject].[dbo].[CovidDeaths]
--WHERE Location like '%AFG%'
Group by Location, population
order by PercentagePopulationDeath desc

--Lets Break Things by continet 

--Showing Contintnet with highest death count per popultion

SELECT continent, Max(cast(total_deaths as int) ) AS TotalDeathcount
FROM [Portfolioproject].[dbo].[Coviddeathcount]
--WHERE Location like '%AFG%'
Where continent is not null
Group by continent
order by TotalDeathcount desc

--Global Numbers

  SELECT  date,  sum(new_cases) as totalNewcases, sum(cast(new_deaths as int)) as totalnewdeaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolioproject].[dbo].[Coviddeathcount]
--WHERE Location like '%AFG%'
where continent is not null
group by date
order by 1,2


 SELECT    sum(new_cases) as totalNewcases, sum(cast(new_deaths as int)) as totalnewdeaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolioproject].[dbo].[Coviddeathcount]
--WHERE Location like '%AFG%'
where continent is not null
--group by date
order by 1,2

--Looking at total population vs vaccination

select* 
from Portfolioproject..Coviddeathcount dea
join Portfolioproject..Covidvaccinationcount vac
on dea.location = vac.location
and dea.date =vac.date

select dea.continent, dea.date,dea.location , dea.date, dea.population , vac.new_vaccinations
from Portfolioproject..Coviddeathcount dea
join Portfolioproject..Covidvaccinationcount vac
on dea.location = vac.location
and dea.date =vac.date
order by 1,2


select dea.continent, dea.date,dea.location , dea.date, dea.population , vac.new_vaccinations
from Portfolioproject..Coviddeathcount dea
join Portfolioproject..Covidvaccinationcount vac
on dea.location = vac.location
and dea.date =vac.date
where dea.continent is not null
order by 1,2,3


 
SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations,
  SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
FROM Portfolioproject..Coviddeathcount dea
JOIN Portfolioproject..Covidvaccinationcount vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS not NULL
ORDER BY 2, 3



---USE CTE

with PopvsVac (continent,location,population,date,new_vaccinations, Rollingpeoplevaccinated)
as
(
SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations,
  SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rollingpeoplevaccinated
---(Rollingpeoplevaccinated/population)*100
from Portfolioproject..Coviddeathcount dea
JOIN Portfolioproject..Covidvaccinationcount vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS not NULL )
--ORDER BY 2, 3)
select *, (Rollingpeoplevaccinated/population)*100
from PopvsVac




--Temp Table
 
drop table if exists #Percentpopulationvaccinated
Create table #Percentpopulationvaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric


--Creating View to store databse for later visulization

Create view  Percentpopulationvaccinated as

SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations,
  SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rollingpeoplevaccinated
---(Rollingpeoplevaccinated/population)*100
from Portfolioproject..Coviddeathcount dea
JOIN Portfolioproject..Covidvaccinationcount vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS not NULL 
--ORDER BY 2, 3)

select * 
from
Percentpopulationvaccinated