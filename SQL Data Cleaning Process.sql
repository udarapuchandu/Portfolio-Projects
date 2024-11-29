/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProjects.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProjects.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


Select * 
from PortfolioProjects.dbo.NashvilleHousing
where PropertyAddress is null
order by ParcelID

SELECT 
    a.ParcelID, 
    a.PropertyAddress AS a_PropertyAddress, 
    b.ParcelID AS b_ParcelID, 
    b.PropertyAddress AS b_PropertyAddress, 
    ISNULL(a.PropertyAddress, b.PropertyAddress) AS UpdatedPropertyAddress
FROM 
    PortfolioProjects.dbo.NashvilleHousing a
JOIN 
    PortfolioProjects.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
WHERE 
    a.PropertyAddress IS NULL;



UPDATE a
SET 
    a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM 
    PortfolioProjects.dbo.NashvilleHousing a
JOIN 
    PortfolioProjects.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
WHERE 
    a.PropertyAddress IS NULL;


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioProjects.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From PortfolioProjects.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From PortfolioProjects.dbo.NashvilleHousing





Select OwnerAddress
From PortfolioProjects.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProjects.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProjects.dbo.NashvilleHousing



--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProjects.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant 
, CASE When SoldAsVacant = 'Y' THEN 'YES'
       When SoldASVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
From PortfolioProjects.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
       When SoldASVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END


--------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE AS (
Select *,
  ROW_NUMBER() OVER(
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				UniqueID
				) row_num

From PortfolioProjects.dbo.NashvilleHousing
--ORDER BY ParcelID
)
Select *
From RowNumCTE
Where Row_num > 1
Order By PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select * 
From PortfolioProjects.dbo.NashvilleHousing

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN SaleDate