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


--Splitting the address into readable form
Select PropertyAddress
From PortfolioProject..NashVilleHousingData

Alter table PortfolioProject..NashVilleHousingData
ADD Address NVARCHAR(255)

Alter table PortfolioProject..NashVilleHousingData
ADD City NVARCHAR(255)

Update PortfolioProject..NashVilleHousingData
Set Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

Update PortfolioProject..NashVilleHousingData
Set City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


--Splitting the Owner's address into readable form
Alter table PortfolioProject..NashVilleHousingData
ADD Owner_Address NVARCHAR(255)

Alter table PortfolioProject..NashVilleHousingData
ADD Owner_City NVARCHAR(255)

Alter table PortfolioProject..NashVilleHousingData
ADD Owner_State NVARCHAR(255)

Update PortfolioProject..NashVilleHousingData
Set Owner_Address = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Update PortfolioProject..NashVilleHousingData
Set Owner_City = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Update PortfolioProject..NashVilleHousingData
Set Owner_State = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)


--Changing Y/N to Yes/No
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject..NashVilleHousingData
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant);

Update PortfolioProject..NashVilleHousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'NO'
						ELSE SoldAsVacant
					END


--Removing Duplicates
WITH RowNumCTE AS (
	Select *, ROW_NUMBER() OVER (Partition by ParcelID, SaleDate, SalePrice, OwnerName, Acreage, LandValue Order by UniqueID, ParcelID) row_num
	FROM PortfolioProject..NashVilleHousingData
)
Select * FROM RowNumCTE
Where row_num > 1

--WE DELETE THE REPEATING ROWS
Delete from RowNumCTE
Where row_num > 1


--Removing the unnecssary columns
Alter table PortfolioProject..NashVilleHousingData
Drop Column PropertyAddress, OwnerAddress, SaleDate

Select * From PortfolioProject..NashVilleHousingData