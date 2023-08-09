/* 
cleaning Data in SQL Queries
*/


select *
from portifolioProject..NashvilleHousing




-- Standarize Date Format

select SaleDate, CONVERT(date,SaleDate)
from portifolioProject..NashvilleHousing

ALTER TABLE portifolioProject..NashvilleHousing
Add salesDate2 Date

Update portifolioProject..NashvilleHousing
SET salesDate2 = Convert(Date,SaleDate)

--ALTER TABLE portifolioProject..NashvilleHousing
--DROP COLUMN SalesDateConverted



-- Populate Property Address

select PropertyAddress 
from portifolioProject..NashvilleHousing
where PropertyAddress is null


select a.UniqueID, a.ParcelID, a.PropertyAddress, b.UniqueID, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from portifolioProject..NashvilleHousing a
join portifolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from portifolioProject..NashvilleHousing a
join portifolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

select a.UniqueID, a.ParcelID, a.PropertyAddress, b.UniqueID, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from portifolioProject..NashvilleHousing a
join portifolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
--where a.PropertyAddress is null




-- Split PropertyAddress By Address and and City


select PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 ,LEN(PropertyAddress)) as City 
from portifolioProject..NashvilleHousing

ALTER TABLE portifolioProject..NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

ALTER TABLE portifolioProject..NashvilleHousing
ADD PropertySplitCity nvarchar(255)


UPDATE portifolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

UPDATE portifolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select PropertyAddress, PropertySplitAddress, PropertySplitCity
from portifolioProject..NashvilleHousing




-- OR
select OwnerAddress
from portifolioProject..NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from portifolioProject..NashvilleHousing
where OwnerAddress is not null



ALTER TABLE portifolioProject..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

ALTER TABLE portifolioProject..NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

ALTER TABLE portifolioProject..NashvilleHousing
ADD OwnerSplitState nvarchar(255)


UPDATE portifolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE portifolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE portifolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



select *
from portifolioProject..NashvilleHousing



-- Change Y and N to YES and NO in Sold As Vacant column

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
from portifolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from portifolioProject..NashvilleHousing


Update portifolioProject..NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
                        When SoldAsVacant = 'N' THEN 'No'
	                    ELSE SoldAsVacant
	               END
from portifolioProject..NashvilleHousing



-- Remove Duplicates 

WITH RowNumCTE as(
Select *, 
    ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) Row_Num

from portifolioProject..NashvilleHousing
)DELETE
from RowNumCTE
where Row_Num > 1
--order by PropertyValue



-- Delete Unsued Columns 

Select * 
From portifolioProject..NashvilleHousing


ALTER TABLE portifolioProject..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict