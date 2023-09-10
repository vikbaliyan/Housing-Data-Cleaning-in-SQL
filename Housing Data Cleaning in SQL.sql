select * from porfolio.dbo.NashvilleHousing	

-------------------------------------------------
--standardize data format

select SaleDateConverted, convert(Date,SaleDate)
from porfolio.dbo.NashvilleHousing

update porfolio.dbo.NashvilleHousing
set SaleDate=convert(Date,SaleDate)

ALTER TABLE porfolio.dbo.NashvilleHousing
add SaleDateConverted date

update porfolio.dbo.NashvilleHousing
set SaleDateConverted=convert(Date,SaleDate)

---------------------------------------------------------------------
-- Populate Property Address Data

select *
from porfolio.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from porfolio.dbo.NashvilleHousing a
join porfolio.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.PropertyAddress, b.PropertyAddress)
from porfolio.dbo.NashvilleHousing a
join porfolio.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

---------------------------------------------------------
--breaking out Address into individuals columns (Address, City, State)

select PropertyAddress
from porfolio.dbo.NashvilleHousing

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)  as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
from porfolio.dbo.NashvilleHousing

ALTER Table porfolio.dbo.NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update porfolio.dbo.NashvilleHousing
set PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER Table porfolio.dbo.NashvilleHousing
add PropertySplitCity nvarchar(255);

update porfolio.dbo.NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

select *
from porfolio.dbo.NashvilleHousing

select OwnerAddress
from Porfolio.dbo.NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from Porfolio.dbo.NashvilleHousing

ALTER Table porfolio.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update porfolio.dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER Table porfolio.dbo.NashvilleHousing
Add OwnerSplitCity varchar(255);

Update porfolio.dbo.NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER Table porfolio.dbo.NashvilleHousing
Add OwnerSplitState varchar(255);

Update porfolio.dbo.NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select *
from porfolio.dbo.NashvilleHousing

----------------------------------------------------
--change Y and N to Yes and No in "Sold as vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from porfolio.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant, 
CASE When SoldAsVacant ='Y' Then 'Yes'
when SoldAsVacant='N' Then 'No'
ELSE SoldAsVacant
END
from porfolio.dbo.NashvilleHousing

Update porfolio.dbo.NashvilleHousing 
SET SoldAsVacant = CASE When SoldAsVacant ='Y' Then 'Yes'
when SoldAsVacant='N' Then 'No'
ELSE SoldAsVacant
END

-------------------------------------------------------------------
--remove duplicates

WITH RowNumCTE AS(
select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY
UniqueID
)
row_num
from porfolio.dbo.NashvilleHousing
)

delete
from RowNumCTE
where row_num>1

-----------------------------------------------------------------
--Delete unused Columns

select*
from Porfolio.dbo.NashvilleHousing

ALTER TABLE Porfolio.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Porfolio.dbo.NashvilleHousing
DROP COLUMN SaleDate