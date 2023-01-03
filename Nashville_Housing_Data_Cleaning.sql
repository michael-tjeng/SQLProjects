-- The below cleans data in SQL queries

SELECT *
FROM dbo.NashvilleHousing

-- The below standardises Date Format
SELECT SaleDateConverted, CONVERT(Date, SaleDate) -- The "Date" syntax converts the existing data into yyyy-mm-dd format
FROM dbo.NashvilleHousing

Update dbo.NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE dbo.NashvilleHousing
ADD SaleDateConverted Date;
Update dbo.NashvilleHousing
SET SaleDateConverted  = CONVERT(Date, SaleDate)

-- Populate Property Address Data
SELECT *
FROM dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Break address into the following columns: Address, City, State
SELECT PropertyAddress
FROM dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) As Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) As Address
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);
Update dbo.NashvilleHousing
SET PropertySplitAddress  = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);
Update dbo.NashvilleHousing
SET PropertySplitCity  = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT*
FROM dbo.NashvilleHousing

SELECT OwnerAddress
FROM dbo.NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3), PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2), PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);
Update dbo.NashvilleHousing
SET OwnerSplitAddress  = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);
Update dbo.NashvilleHousing
SET OwnerSplitCity  = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);
Update dbo.NashvilleHousing
SET OwnerSplitState  = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

SELECT*
FROM dbo.NashvilleHousing

-- Change Y and N to Yes and No respectively in "Sold as Vacant" column
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

Select SoldAsVacant, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
					 WHEN SoldAsVacant = 'N' THEN 'No'
					 ELSE SoldAsVacant
					 End
FROM dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
					WHEN SoldAsVacant = 'N' THEN 'No'
					ELSE SoldAsVacant
					End



-- Remove Duplicates
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID 
				 ) row_num

FROM dbo.NashvilleHousing
)
-- Use DELETE to delete the duplicates
DELETE
FROM RowNumCTE
WHERE row_num > 1

-- Then use the below to check
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID 
				 ) row_num

FROM dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

SELECT *
FROM dbo.NashvilleHousing



-- Detele Unused Columns (such as OwnerAddress, TaxDistrict, PropertyAddress, SaleDate) as these old columns have been cleaned

SELECT *
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN SaleDate