Select * FROM PortfolioProject..CovidDeaths
Order by 3,4

--Select * from PortfolioProject.dbo.CovidVaccinations
--Order by 3,4

--Select Location, date, population, total_cases,new_cases, total_deaths
--FROM PortfolioProject..CovidDeaths
--Order by 1

--Total cases vs Total deaths
Select Location, date, total_cases, total_deaths, cast(total_deaths as float) / cast(total_cases as float) * 100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
where total_cases is not null
and continent is not null
order by 1


--Total cases vs Population
Select Location, population, total_cases, cast(total_cases as float) / population * 100 as PopulationInfectedPercentage
From PortfolioProject..CovidDeaths
where continent is not null
and total_cases is not null
order by 1


--Death Percentage for every country
Select Location, Max(cast(total_cases as float)) as Total_Cases, Max(cast(total_deaths as float)) as Total_Deaths, Max(cast(total_deaths as float))/Max(cast(total_cases as float)) * 100 as Death_Percentage
From PortfolioProject..CovidDeaths
where continent is not null
Group by Location
order by 4 desc

--Most affected country
SELECT Location, Population, MAX(CAST(total_cases AS float)) AS Total_Cases, (MAX(CAST(total_cases AS float)) / Population) * 100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY 4 DESC;

--Most Affected Continent/Region
Select location, population, MAX(CAST(total_cases AS float)), (MAX(CAST(total_cases AS float)) / Population) * 100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY Location, Population
ORDER BY 4 DESC;


--Total cases per day along with the death count
Select date, Sum(CAST(new_cases AS INT)) as Total_Cases, Sum(CAST(new_deaths AS INT)) as Total_deaths
From PortfolioProject..CovidDeaths
Where continent is not null
group by date
order by 1,2

--Total case in the world including the total deaths and death percentage
Select Sum(convert(int, new_cases)) as Total_Cases, Sum(convert(int, new_deaths)) as Total_deaths, sum(convert(float, new_deaths)) / sum(cast(new_cases as float)) * 100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1, 2




