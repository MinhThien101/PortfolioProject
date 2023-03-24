/*

Cleaning data in SQL Queries

*/

Select *
From Pofolio.dbo.NashvilleHousing

------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted--, Convert(date, SaleDate) as Date
From Pofolio.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(date, SaleDate)

Alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(date, SaleDate)

------------------------------------------------------------------

-- Populate Property Address Data

Select *
From Pofolio.dbo.NashvilleHousing
Where PropertyAddress is not null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, Isnull(a.PropertyAddress,b.PropertyAddress)
From Pofolio.dbo.NashvilleHousing a
JOIN Pofolio.dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
Set PropertyAddress = Isnull(a.PropertyAddress,b.PropertyAddress)
From Pofolio.dbo.NashvilleHousing a
JOIN Pofolio.dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-----------------------------------------------------------------------

-- Breaking out Address into individual column (Address, city, state)

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
	   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From Pofolio.dbo.NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- Other way to break Address into individual column

Select
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
From NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-------------------------------------------------------------------

-- Change Y and N into Yes and No in 'Sold as Vacant' field

Select DISTINCT SoldAsVacant, count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant

Select SoldAsVacant,
	   Case When SoldAsVacant = 'Y' Then 'Yes'
			When SoldAsVacant = 'N' Then 'No'
			Else SoldAsVacant
	   End
From NashvilleHousing
--Where SoldAsVacant = 'Y'
--   or SoldAsVacant = 'N'

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						Else SoldAsVacant
				   End

------------------------------------------------------------------------

-- Remove duplicates

With cte_dup as (
Select *,
	   ROW_NUMBER() OVER(
	   PARTITION BY ParcelID,
				    PropertyAddress,
				    SalePrice,
				    SaleDate,
				    LegalReference
	   ORDER BY UniqueID) AS row_num					
From NashvilleHousing )

Select *
From cte_dup
Where row_num > 1

----------------------------------------------------------------------------

--Remove unuesd columns

Select *
From NashvilleHousing

Alter table NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate