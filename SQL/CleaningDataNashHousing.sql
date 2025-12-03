/*
Objective: Clean the data and Update the table
*/

select *
from portofolio..CleaningDataHousing;

-- Update format SaleDate into date format
alter table portofolio..CleaningDataHousing
add SaleDateConverted Date;

update portofolio..CleaningDataHousing
set SaleDateConverted = convert(date,SaleDate);

-- Fill null data at property address data
select nh1.ParcelID, nh1.PropertyAddress, nh2.ParcelID, nh2.PropertyAddress
from portofolio..CleaningDataHousing  nh1
join portofolio..CleaningDataHousing  nh2 
	on nh1.ParcelID = nh2.ParcelID 
	and nh1.UniqueID != nh2.UniqueID
where nh1.PropertyAddress is null;


update nh1
set PropertyAddress = isnull(nh1.PropertyAddress,nh2.PropertyAddress)
from portofolio..CleaningDataHousing  nh1
join portofolio..CleaningDataHousing  nh2 
	on nh1.ParcelID = nh2.ParcelID 
	and nh1.UniqueID != nh2.UniqueID
where nh1.PropertyAddress is null;

-- Split Propert Address and add to table

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
	   SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress))
from portofolio..CleaningDataHousing;

alter table portofolio..CleaningDataHousing
add PropertySplitAddress varchar(255);

update portofolio..CleaningDataHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

alter table portofolio..CleaningDataHousing
add PropertySplitCity varchar(255);

update portofolio..CleaningDataHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress));

select PropertySplitAddress, PropertySplitCity
from portofolio..CleaningDataHousing;

-- Split Owner Address
select 
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from portofolio..CleaningDataHousing;

alter table portofolio..CleaningDataHousing
add OwnerSplitAddress varchar(255);

update portofolio..CleaningDataHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3);

alter table portofolio..CleaningDataHousing
add OwnerSplitCity varchar(255);

update portofolio..CleaningDataHousing
set  OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2);

alter table portofolio..CleaningDataHousing
add OwnerSplitState varchar(255);

update portofolio..CleaningDataHousing
set  OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1);

select *
from portofolio..CleaningDataHousing;

-- Change 'N' to 'No' and 'Y' to 'Yes' in SoldAsVacant 
select SoldAsVacant, 
case when SoldAsVacant = 'N' then 'No'
	 when SoldasVacant = 'Y' then 'Yes'
	 else SoldasVacant
end as SoldAsVacant2
from portofolio..CleaningDataHousing;

update portofolio..CleaningDataHousing
set SoldAsVacant = case when SoldAsVacant = 'N' then 'No'
	 when SoldasVacant = 'Y' then 'Yes'
	 else SoldasVacant
end;

select distinct(SoldAsVacant), count(SoldAsVacant)
from portofolio..CleaningDataHousing
group by SoldAsVacant;

-- Remove Duplicates
with RemoveDuplicates as (
select 
*,
ROW_NUMBER() over 
(partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) as row_num
from portofolio..CleaningDataHousing
)
DELETE 
from RemoveDuplicates
where row_num >1;

with RemoveDuplicates as (
select 
*,
ROW_NUMBER() over 
(partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) as row_num
from portofolio..CleaningDataHousing
)
Select * 
from RemoveDuplicates
where row_num >1;

-- Delete Unused Column
Alter table portofolio..CleaningDataHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress;

Alter table portofolio..CleaningDataHousing
drop column SaleDate;
