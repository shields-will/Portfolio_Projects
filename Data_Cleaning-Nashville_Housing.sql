-- MySQL syntax
USE data_cleaning;

SELECT *
FROM housing;


-- Convert Date as string to Datetime

SELECT SaleDate, STR_TO_DATE(SaleDate, '%M %d, %Y')
FROM housing;

UPDATE housing
SET SALEDATE= STR_TO_DATE(SaleDate, '%M %d, %Y');


-- ---------------------------------------------------
-- Populate Property Address data


SELECT *
FROM housing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

-- Self join to identify matching parcels and addresses
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM housing AS a
JOIN housing AS b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- Update Join statement to fill these blanks

UPDATE housing AS a
JOIN housing AS b 
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;



-- ---------------------------------------------------
-- Breaking out PropertyAddress into Inidividual columns (Address, City)


SELECT PropertyAddress
FROM housing;

SELECT
SUBSTRING(PropertyAddress,1, LOCATE(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,LOCATE(',', PropertyAddress)+2) AS City
FROM housing;

-- Add columns for Property Street & City

ALTER TABLE housing
ADD PropertyStreet CHAR(255);

ALTER TABLE housing
ADD PropertyCity CHAR(255);

UPDATE housing
SET PropertyStreet = SUBSTRING(PropertyAddress,1, LOCATE(',', PropertyAddress)-1);

UPDATE housing
SET PropertyCity = SUBSTRING(PropertyAddress,LOCATE(',', PropertyAddress)+2);



-- ---------------------------------------------------
-- Breaking out OwnerAddress into Inidividual columns (Address, City, State)



SELECT OwnerAddress
FROM housing;

SELECT
SUBSTRING_INDEX(OwnerAddress, ',', 1) AS OwnerStreet,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2),',',1) AS OwnerCity,
SUBSTRING_INDEX(OwnerAddress, ',', -1) AS OwnerState
FROM housing;

-- Add columns for Owner Street, City, State

ALTER TABLE housing
ADD OwnerStreet CHAR(255);

ALTER TABLE housing
ADD OwnerCity CHAR(255);

ALTER TABLE housing
ADD OwnerState CHAR (255);

UPDATE housing
SET OwnerStreet = SUBSTRING_INDEX(OwnerAddress, ',', 1);

UPDATE housing
SET OwnerCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2),',',1);

Update housing
SET OwnerState = SUBSTRING_INDEX(OwnerAddress, ',', -1);


-- ---------------------------------------------------
-- Clean SoldAsVacant


SELECT DISTINCT SoldAsVacant, COUNT(*)
FROM housing
GROUP BY 1
ORDER BY 2;

SELECT SoldAsVacant, CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END AS SoldAsVacant2
FROM housing;

UPDATE housing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END;
    
    
    
-- ---------------------------------------------------
-- Remove Duplicates (Best practice, don't do to raw data)



WITH RowNumCTE AS ( -- CTE to bring Window function results out of window function
SELECT *, ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
                LegalReference -- Partition by a set of multiple fields that should denote a unique instance of property
                ORDER BY PropertyAddress) AS row_num -- Window function to assign a row number to each line these instances
FROM housing)
SELECT *
FROM RowNumCTE
WHERE row_num > 1 -- >1 results are duplicate results
ORDER BY PropertyAddress; 


WITH RowNumCTE AS ( -- CTE to bring Window function results out of window function
SELECT *, ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
                LegalReference -- Partition by a set of multiple fields that should denote a unique instance of property
                ORDER BY PropertyAddress) AS row_num -- Window function to assign a row number to each line these instances
FROM housing)
DELETE FROM housing
USING housing
JOIN RowNumCTE 
	ON housing.UniqueID = RowNumCTE.UniqueID
WHERE row_num > 1;
-- ORDER BY PropertyAddress; -- >1 results are duplicate results


-- ---------------------------------------------------
-- Remove Unused Columns (Best practice, don't do do raw data. Just for things like views)


ALTER TABLE housing
DROP COLUMN PropertyAddress,
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict;

-- ---------------------------------------------------
-- Clean extra spaces from addresses (could have done before splitting, didn't notice)

UPDATE housing
SET PropertyStreet = REGEXP_REPLACE(PropertyStreet,' +', ' ');

UPDATE housing
SET PropertyCity = REGEXP_REPLACE(PropertyCity,' +', ' ');

UPDATE housing
SET OwnerStreet = REGEXP_REPLACE(OwnerStreet,' +', ' ');

UPDATE housing
SET OwnerCity = REGEXP_REPLACE(OwnerCity,' +', ' ');
