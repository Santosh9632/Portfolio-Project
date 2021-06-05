-- Cleaning data in SQL
SELECT *
FROM ProjectPortfolio..nash_data;

SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM ProjectPortfolio..nash_data;


ALTER TABLE ProjectPortfolio..nash_data
ADD SaleDateConverted Date;

UPDATE ProjectPortfolio..nash_data
SET SaleDateConverted=CONVERT(Date, SaleDate);

--Populate Property Address data

SELECT *
FROM ProjectPortfolio..nash_data
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjectPortfolio..nash_data a
JOIN ProjectPortfolio..nash_data b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjectPortfolio..nash_data a
JOIN ProjectPortfolio..nash_data b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]

-- Breaking out Address into Individual columns(Address, City, State)

SELECT PropertyAddress
FROM ProjectPortfolio..nash_data
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID;

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM ProjectPortfolio..nash_data

ALTER TABLE ProjectPortfolio..nash_data
ADD PropertySplitAddress VARCHAR(255);

UPDATE ProjectPortfolio..nash_data
SET PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE ProjectPortfolio..nash_data
ADD PropertySplitCity VARCHAR(255);

UPDATE ProjectPortfolio..nash_data
SET PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));


-- Updating Owner Address column

SELECT OwnerAddress
FROM ProjectPortfolio..nash_data;

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM ProjectPortfolio..nash_data;

ALTER TABLE ProjectPortfolio..nash_data
ADD OwnerSplitAddress VARCHAR(255);

UPDATE ProjectPortfolio..nash_data
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE ProjectPortfolio..nash_data
ADD OwnerSplitCity VARCHAR(255);

UPDATE ProjectPortfolio..nash_data
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE ProjectPortfolio..nash_data
ADD OwnerSplitState VARCHAR(255);

UPDATE ProjectPortfolio..nash_data
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM ProjectPortfolio..nash_data
GROUP BY SoldAsVacant;

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM ProjectPortfolio..nash_data

UPDATE ProjectPortfolio..nash_data
SET SoldAsVacant=CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' THEN 'No'
	ELSE SoldAsVacant
	END

--Remove Duplicates

WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY UniqueID) row_num
FROM ProjectPortfolio..nash_data
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num>1
ORDER BY PropertyAddress


--Delete Unused Columns

ALTER TABLE ProjectPortfolio..nash_data
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE ProjectPortfolio..nash_data
DROP COLUMN SaleDate

