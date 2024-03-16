--Entire data
Select * From PortfolioProject..NashVilleHousingData

Select SaleDate, Convert(date, SaleDate)
From PortfolioProject..NashVilleHousingData

Update PortfolioProject..NashVilleHousingData
SET SaleDate = Convert(date, SaleDate)
where SaleDate is not null

--So here when I excuted this query it didn't work, so we create a new column then paste the value there and drop the previous column
Alter table PortfolioProject..NashVilleHousingData
Add Sale_Date date;

Update PortfolioProject..NashVilleHousingData
SET Sale_Date = Convert(date, SaleDate)

Alter table PortfolioProject..NashVilleHousingData
drop SaleDate


--Property Address, Some of the address values have null but according to the PropertID there is a proper property id, so we replace them witht the property address we know
Select PropertyAddress 
From PortfolioProject..NashVilleHousingData
Where PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject..NashVilleHousingData a
JOIN PortfolioProject..NashVilleHousingData b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
order by a.ParcelID

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashVilleHousingData a
JOIN PortfolioProject..NashVilleHousingData b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null