select * from portfolio_project..[Nashville Housing]


-----------------------------------------------------------

--Standardize Date Format

Select SaleDate,cast(SaleDate as date) as Date
from portfolio_project..[Nashville Housing]

Update [Nashville Housing]
Set SaleDate = Convert(date,SaleDate)

Select SaleDateConverted,cast(SaleDate as date) as Date
from portfolio_project..[Nashville Housing]

Alter Table [Nashville Housing]
Add SaleDateConverted Date

Update [Nashville Housing]
Set SaleDateConverted = Convert(date,SaleDate)


------------------------------------------------------

--Populate Property Address Data

Select *
from portfolio_project..[Nashville Housing]
--where PropertyAddress is null
order by ParcelID


Select f.ParcelID,f.PropertyAddress,s.ParcelID,s.PropertyAddress,isnull(f.PropertyAddress,s.PropertyAddress) from portfolio_project..[Nashville Housing] f, portfolio_project..[Nashville Housing] s where f.UniqueID <> s.UniqueID and 
f.ParcelID = s.ParcelID and f.PropertyAddress is null  



update f
set PropertyAddress = isnull(f.PropertyAddress,s.PropertyAddress) from portfolio_project..[Nashville Housing] f, portfolio_project..[Nashville Housing] s where f.UniqueID <> s.UniqueID and 
f.ParcelID = s.ParcelID and f.PropertyAddress is null  

 
--------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (address,City,State)


Select PropertyAddress
from portfolio_project..[Nashville Housing]


Select PropertyAddress,SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as Address
from portfolio_project..[Nashville Housing]


Alter Table [Nashville Housing]
Add PropertySplitAddress nvarchar(255)

Update [Nashville Housing]
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) 

Alter Table [Nashville Housing]
Add PropertySplitCity nvarchar(255)

Update [Nashville Housing]
Set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) 


select PropertySplitCity,PropertySplitAddress from portfolio_project..[Nashville Housing]


Select OwnerAddress
from portfolio_project..[Nashville Housing]

Select parsename(replace(OwnerAddress,',','.'),3),parsename(replace(OwnerAddress,',','.'),2),parsename(replace(OwnerAddress,',','.'),1)
from portfolio_project..[Nashville Housing]


Alter Table [Nashville Housing]
Add OwnerSplitAddress nvarchar(255)

Update [Nashville Housing]
Set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'),3)


Alter Table [Nashville Housing]
Add OwnerSplitCity nvarchar(255)

Update [Nashville Housing]
Set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),2)


Alter Table [Nashville Housing]
Add OwnerSplitState nvarchar(255)

Update [Nashville Housing]
Set OwnerSplitState = parsename(replace(OwnerAddress,',','.'),1)

select * from portfolio_project..[Nashville Housing]



select PropertyAddress from portfolio_project..[Nashville Housing]

select PropertyAddress,SUBSTRING(PropertyAddress,1,Charindex(',',PropertyAddress)-1), 
	   SUBSTRING(PropertyAddress,Charindex(',',PropertyAddress)+1,len(PropertyAddress))
	   from portfolio_project..[Nashville Housing]

select SUBSTRING(PropertyAddress,Charindex(',',PropertyAddress)+1,len(PropertyAddress)) from portfolio_project..[Nashville Housing]


select OwnerAddress,PARSENAME(Replace(OwnerAddress,',','.'),3),PARSENAME(Replace(OwnerAddress,',','.'),2),PARSENAME(Replace(OwnerAddress,',','.'),1) from portfolio_project..[Nashville Housing]


------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant),count(SoldAsVacant) from portfolio_project..[Nashville Housing]
group by SoldAsVacant
order by 2


Select SoldAsVacant
,CASE when SoldAsVacant = 'Y' Then 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 else SoldAsVacant 
	 end
from portfolio_project..[Nashville Housing]


update [Nashville Housing]
set SoldAsVacant = CASE when SoldAsVacant = 'Y' Then 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 else SoldAsVacant 
	 end


-----------------------------------------------------------------------------------------------

--Remove Duplicates

with remove_duplicates
as
	(select *, 
	ROW_NUMBER() OVER (Partition by ParcelID,PropertyAddress
	,SalePrice,SaleDate,LegalReference order by UniqueID
	) row_num 


from portfolio_project..[Nashville Housing]
--order by ParcelID

)
select * from remove_duplicates
where row_num>1
--order by PropertyAddress

----------------------------------------------------------------------------------


--Delete unused Columns


select * from portfolio_project..[Nashville Housing]


Alter table portfolio_project..[Nashville Housing]
Drop Column OwnerAddress,TaxDistrict,PropertyAddress,SaleDate
