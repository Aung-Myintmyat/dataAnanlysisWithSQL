/*

Cleaning Data in SQL Queries

*/


Select *
From NashvilleHousing;

  --------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, STR_TO_DATE(SaleDate, '%M %d, %Y') 
FROM NashvilleHousing;

Update NashvilleHousing
SET SaleDate = STR_TO_DATE(SaleDate, '%M %d, %Y');



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT PropertyAddress
FROM NashvilleHousing
 WHERE PropertyAddress = '';
-- ORDER BY ParcelID;

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,
CASE 
        WHEN a.PropertyAddress = '' THEN b.PropertyAddress 
        ELSE a.PropertyAddress 
    END 
FROM NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress = '';

UPDATE NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress = '';
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM NashvilleHousing;
 -- WHERE PropertyAddress = '';
-- ORDER BY ParcelID;

SELECT
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, LENGTH(PropertyAddress)) AS Address
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress varchar(225);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity varchar(225);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, LENGTH(PropertyAddress)) ;

SELECT OwnerAddress
FROM NashvilleHousing;

SELECT 
    SUBSTRING_INDEX(OwnerAddress, ',', 1) ,   -- Extracts the last part after the last comma
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),  -- Extracts the second-to-last part
    SUBSTRING_INDEX(OwnerAddress, ',', -1)     -- Extracts the first part
FROM NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress varchar(225);

UPDATE NashvilleHousing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1) ;

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity varchar(225);

UPDATE NashvilleHousing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) ;


ALTER TABLE NashvilleHousing
ADD OwnerSplitState varchar(225);

UPDATE NashvilleHousing
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1) ;

-- ALTER TABLE NashvilleHousing
-- DROP COLUMN OwnerSplitDate ;


SELECT *
FROM NashvilleHousing;



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N'  THEN 'No'
    ELSE SoldAsVacant
    END
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N'  THEN 'No'
    ELSE SoldAsVacant
    END;


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

SELECT *
FROM NashvilleHousing
WHERE UniqueID IN (
    SELECT UniqueID
    FROM (
        SELECT UniqueID,
            ROW_NUMBER() OVER (
                PARTITION BY ParcelID,
                             PropertyAddress,
                             SalePrice,
                             SaleDate,
                             LegalReference
                ORDER BY UniqueID
            ) row_num
        FROM NashvilleHousing
    ) sub
    WHERE sub.row_num > 1
);






---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


ALTER TABLE NashvilleHousing DROP COLUMN OwnerAddress;
ALTER TABLE NashvilleHousing DROP COLUMN TaxDistrict;
ALTER TABLE NashvilleHousing DROP COLUMN PropertyAddress;





















-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


-- sp_configure 'show advanced options', 1;
-- RECONFIGURE;
-- GO
-- sp_configure 'Ad Hoc Distributed Queries', 1;
-- RECONFIGURE;
-- GO


-- USE PortfolioProject 

-- GO 

-- EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

-- GO 

-- EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

-- GO 


---- Using BULK INSERT

-- USE PortfolioProject;
-- GO
-- BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
-- );
-- GO


----  Using OPENROWSET
-- USE PortfolioProject;
-- GO
-- SELECT * INTO nashvilleHousing
-- FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
-- GO
