Select * from PortfolioProject..CovidVaccinations
order by 3 ASC

Select * From PortfolioProject..CovidDeaths
order by 3 ASC

--Total Deaths per million vs Total Cases per million
Select location, continent, date, total_cases_per_million, total_deaths_per_million
From  PortfolioProject..CovidDeaths
where continent is not null
order by 1

	--Finding the max of TCPM and TDPM
	Select location, continent, date, MAX(Convert(float, total_cases_per_million)) as Maximum_TCPM
	From  PortfolioProject..CovidDeaths
	Where continent is not null
	Group by location
	Having count(*) = 1
	Order by 1

--Vaccinations vs deaths on day-to-day basis
Select dea.location, dea.continent, dea.date, vac.new_vaccinations, dea.new_deaths
from PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 1,3


--Total vaccinations and deaths per country on a daily basis

Select location, date, continent, new_vaccinations, Sum(cast(new_vaccinations as float)) OVER (partition by location) as Total_vaccinated
From PortfolioProject..CovidVaccinations
where continent is not null
order by 1,3

Select location, date, continent, new_vaccinations, Sum(cast(new_vaccinations as float)) OVER (partition by location order by location, date) as Total_vaccinated
From PortfolioProject..CovidVaccinations
where continent is not null
order by 1,3

Select vac.location, vac.date, vac.continent, dea.population, dea.new_deaths, vac.new_vaccinations, 
Sum(cast(vac.new_vaccinations as float)) OVER (partition by vac.location order by vac.location, vac.date) as Total_vaccinated,
Sum(convert(float, dea.new_deaths)) OVER (Partition by dea.location order by dea.location, dea.date) as Total_Deaths
From PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
ON dea.location = vac.location
and dea.date = vac.date
where vac.continent is not null


--Populaton of a country vaccincated (Using CTEs)
WITH PopulationVac (location, date, continent, population, new_vaccinations, Total_vaccinated) as
(
	Select vac.location, vac.date, vac.continent, dea.population, vac.new_vaccinations, 
	Sum(cast(vac.new_vaccinations as float)) OVER (partition by vac.location order by vac.location, vac.date) as Total_vaccinated
	From PortfolioProject..CovidVaccinations vac
	JOIN PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location
	and dea.date = vac.date
	where vac.continent is not null
)
Select *, (Total_vaccinated / population * 100) as Population_vaccinated
From PopulationVac

--Population of each country vaccinated (Using temp tables)
Drop table if exists #PopulationVaccinatedTemp
Create table #PopulationVaccinatedTemp
(
	Location nvarchar(255),
	Continent nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	Total_Vaccinated float
)

Insert into #PopulationVaccinatedTemp
Select vac.location, vac.continent, vac.date,  dea.population, vac.new_vaccinations, 
	Sum(cast(vac.new_vaccinations as float)) OVER (partition by vac.location order by vac.location, vac.date) as Total_vaccinated
	From PortfolioProject..CovidVaccinations vac
	JOIN PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location
	and dea.date = vac.date
	where vac.continent is not null

Select *, (Total_vaccinated/Population)*100 as PercentagePopulationVaccinated
From #PopulationVaccinatedTemp

--Creating our table views
Create View PopulationVaccinatedTable as 
Select vac.location, vac.continent, vac.date,  dea.population, vac.new_vaccinations, 
	Sum(cast(vac.new_vaccinations as float)) OVER (partition by vac.location order by vac.location, vac.date) as Total_vaccinated
	From PortfolioProject..CovidVaccinations vac
	JOIN PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location
	and dea.date = vac.date
	where vac.continent is not null

Create View PopulationDeathAndVaccinated as
Select vac.location, vac.date, vac.continent, dea.population, dea.new_deaths, vac.new_vaccinations, 
	Sum(cast(vac.new_vaccinations as float)) OVER (partition by vac.location order by vac.location, vac.date) as Total_vaccinated,
	Sum(convert(float, dea.new_deaths)) OVER (Partition by dea.location order by dea.location, dea.date) as Total_Deaths
	From PortfolioProject..CovidVaccinations vac
	JOIN PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location
	and dea.date = vac.date
	where vac.continent is not null

Create View NewVaccination_NewDeaths as
Select dea.location, dea.continent, dea.date, vac.new_vaccinations, dea.new_deaths
	from PortfolioProject..CovidVaccinations vac
	JOIN PortfolioProject..CovidDeaths dea
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null