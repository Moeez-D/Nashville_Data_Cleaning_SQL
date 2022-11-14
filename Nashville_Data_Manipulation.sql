--Cleaning Data in SQL

Select *
from Nashville..Housing

--Standardizing Date Format for SaleDate
-- here we updated column named SaleDate in Date format 

Select SaleDate, Convert(Date,SaleDate) as converted
From Nashville..Housing

Update Nashville..Housing
SET SaleDate = Convert(Date,SaleDate)

--Method 2 to do the same above thing, here we created another column named SaleDateConverted 

Alter Table Nashville..Housing
Add SaleDateConverted Date;

Update Nashville..Housing
SET SaleDateConverted = Convert(Date,SaleDate)

Select SaleDateConverted
From Nashville..Housing

--Populating Property Address Data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Nashville..Housing a
Join Nashville..Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Nashville..Housing a
Join Nashville..Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out Address into individual columns using SUBSTRING

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) as Address1,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress) ) as Address2
from Nashville..Housing

--Adding these two as seperate new columns

--Column1

Alter Table Nashville..Housing
Add PropertySplitAddress Nvarchar(255);

Update Nashville..Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 )

--Column2

Alter Table Nashville..Housing
Add PropertySplitCity Nvarchar(255);

Update Nashville..Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress) )


--Breaking out OwnerAddress into individual columns using PARSENAME

select 
PARSENAME(Replace(OwnerAddress,',','.'),3) as OwnerAddressAPT,
PARSENAME(Replace(OwnerAddress,',','.'),2) as OwnerAddressCity,
PARSENAME(Replace(OwnerAddress,',','.'),1) as OwnerAddressState
From Nashville..Housing

--Adding these 3 as seperate new columns

--Column1

Alter Table Nashville..Housing
Add OwnerAddressAPT Nvarchar(255);

Update Nashville..Housing
SET OwnerAddressAPT = PARSENAME(Replace(OwnerAddress,',','.'),3)

--Column2

Alter Table Nashville..Housing
Add OwnerAddressCity Nvarchar(255);

Update Nashville..Housing
SET OwnerAddressCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

--Column3

Alter Table Nashville..Housing
Add OwnerAddressState Nvarchar(255);

Update Nashville..Housing
SET OwnerAddressState = PARSENAME(Replace(OwnerAddress,',','.'),1)


--Changing Y and N as Yes and No in "Sold as Vacant" field

--looking at the frequency of each occurance
Select distinct(Soldasvacant), COUNT(SoldAsVacant)
From Nashville..Housing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case when SoldAsVacant='Y' Then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End
From Nashville..Housing
Where SoldAsVacant = 'Y' or SoldAsVacant = 'N' 

Update Nashville..Housing
SET SoldAsVacant = 
Case when SoldAsVacant='Y' Then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End

--Remove Duplicates

with RowNumberCTE as
(
Select *,
ROW_NUMBER() over(Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference Order by uniqueID) Row_num
from Nashville..Housing
) 

/* use this for deletion of duplicate values
Delete
from RowNumberCTE
where Row_num > 1
*/

Select * 
from RowNumberCTE
where Row_num > 1
Order by [UniqueID ]

--Delete Unused Columns

Select *
From Nashville..Housing

Alter Table Nashville..Housing
Drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table Nashville..Housing
Drop column SaleDate

Select *
From Nashville..Housing