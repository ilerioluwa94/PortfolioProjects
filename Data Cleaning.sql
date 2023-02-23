/*
Cleaning Data in SQL Queries
*/

Select * from Portfolio_Project..Nashvillehousing;
----------------------------------------------------------------------------------------------

-- Standardize Date Format
Select SaleDate, CONVERT(DATE,SaleDate) 
from Portfolio_Project..Nashvillehousing;

--UPDATE Nashvillehousing /* Not working
--SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE Nashvillehousing
ADD SaleDateConverted DATE;

UPDATE Nashvillehousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)


Select SaleDateConverted, CONVERT(DATE,SaleDate) 
from Portfolio_Project..Nashvillehousing

----------------------------------------------------------------------------------------------
-- Populate Property Address Data
Select *
from Portfolio_Project..Nashvillehousing
--where PropertyAddress is null
order by ParcelID

Select  a.[UniqueID ] ,a.ParcelID, a.PropertyAddress, b.[UniqueID ],b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Project..Nashvillehousing a
join Portfolio_Project..Nashvillehousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Project..Nashvillehousing a
join Portfolio_Project..Nashvillehousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-----------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from Portfolio_Project..Nashvillehousing
--where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, CHARINDEX(',', PropertyAddress),
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
from Portfolio_Project..Nashvillehousing

-- Updating the table by adding two new columns
use Portfolio_Project
ALTER TABLE Nashvillehousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE Nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Nashvillehousing
ADD PropertySplitCity Nvarchar(255)

UPDATE Nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

--select * from Portfolio_Project..Nashvillehousing

------------------------------------------------------------------------------
-- Breaking OwnerAddress into Individual columns Address, City and State

select OwnerAddress from Portfolio_Project..Nashvillehousing

-- select PARSENAME(OwnerAddress, 1) from Portfolio_Project..Nashvillehousing -- Not working 

select PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) As OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) As OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) As OwnerSplitState
from Portfolio_Project..Nashvillehousing

-- Updating the table with the three new columns
ALTER TABLE Nashvillehousing
ADD OwnerSplitAddress Nvarchar(255),
	OwnerSplitCity Nvarchar(255),
	OwnerSplitState Nvarchar(255)

UPDATE Nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

UPDATE Nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

UPDATE Nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

-------------------------------------------------------------------------
-- Change Y and N to Yes and No respectively in SoldAsVacant field

UPDATE Nashvillehousing
SET SoldAsVacant = 'Yes'
where SoldAsVacant = 'Y'

UPDATE Nashvillehousing
SET SoldAsVacant = 'No'
where SoldAsVacant = 'N'

------------------------------------------------------------------------
--Remove Duplicates
with RowCTE as(
select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID) as Row_Num
from Portfolio_Project..Nashvillehousing) --order by ParcelID
Delete from RowCTE
where Row_Num > 1

------------------------------------------------------------------
-- Delete Unused columns
select distinct(SoldAsVacant) from Portfolio_Project..Nashvillehousing

ALTER TABLE Portfolio_Project..Nashvillehousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

select * from Portfolio_Project..Nashvillehousing