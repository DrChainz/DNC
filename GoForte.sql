-- select count(*) from [CarData].[List_002_Clean__2015-03-18_9.54AM]

USE [PrivateReserve]
GO

/****** Object:  Table [CarData].[List_002_Clean__2015-03-18_9.54AM]    Script Date: 3/18/2015 11:47:23 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO


select max(len(middle_initial)) from [CarData].[List_001_Clean__2015-03-18_9.54AM]

update [CarData].[List_002_Clean__2015-03-18_9.54AM] set postal_code = '0' + postal_code where len(postal_code) = 4



select len(postal_code), count(*)
from [CarData].[List_002_Clean__2015-03-18_9.54AM]
group by len(postal_code)

select state, count(*)
from [CarData].[List_002_Clean__2015-03-18_9.54AM]
where len(postal_code) = 8
group by state

select top 100 postal_code, substring(postal_code,1,5) + '-' + substring(postal_code,6,4)
from [CarData].[List_002_Clean__2015-03-18_9.54AM]
where len(postal_code) = 9


update [CarData].[List_002_Clean__2015-03-18_9.54AM]
set postal_code = substring(postal_code,1,5) + '-' + substring(postal_code,6,4)
where len(postal_code) = 9

select top 100 postal_code from [CarData].[List_002_Clean__2015-03-18_9.54AM] where len(postal_code) = 8

update [CarData].[List_002_Clean__2015-03-18_9.54AM] set postal_code = '0' + postal_code where len(postal_code) = 8


update [CarData].[List_002_Clean__2015-03-18_9.54AM] set postal_code = substring(postal_code,1,5) where len(postal_code) = 8 and State = 'TX'

-- ********************************************************************************************************************************
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
truncate table [CarData].[GoForte_Extract]

INSERT [CarData].[GoForte_Extract] ( Listcode, Appnumber) -- , Last, First, Middle, Address, City, State, Zip, Phone, VIN, Year, Model, Make, Odom)
select distinct 'QSM_2015_03_Mar_18' ListCode, Phone_number Appnumber
FROM [CarData].[List_002_Clean__2015-03-18_9.54AM]

update [CarData].[GoForte_Extract]
	SET	Last = substring(a.last_name,1,30),
		First = substring(a.first_name,1,30),
		Middle = substring(a.middle_initial,1,1),
		Address = substring(a.address1,1,50),
		City = substring(a.city,1,30),
		State = substring(a.state,1,2),
		Zip = rtrim(substring(a.Postal_code,1,5)),
		Phone = substring(a.phone_number,1,10),
		VIN = a.vin,
		Year = substring(a.year,1,4),
		Model = a.model,
		Make = a.make,
		Odom = substring(a.Mileage,1,10)
FROM [CarData].[GoForte_Extract] x, [CarData].[List_002_Clean__2015-03-18_9.54AM] a
WHERE appnumber = phone_number
  and len(a.vin) = 17



select top 100 * from [CarData].[GoForte_Extract]


delete [CarData].[GoForte_Extract] where vin is NULL

update [CarData].[GoForte_Extract] set ListCode = 'QSM_2015_03_Mar_18'

select top 1000 * from [CarData].[GoForte_Extract]





select max(len(vin)) from [CarData].[List_002_Clean__2015-03-18_9.54AM]




select 'QSM_2015_03_Mar_18' ListCode, Phone_number Appnumber, last_name Last, First_name First, Middle_initial Middle,
	Address1 Address, City, State, rtrim(substring(Postal_code,1,5)) Zip,
	Phone_Number Phone, Vin, Year, Model, Make, Mileage Odom
FROM [CarData].[List_002_Clean__2015-03-18_9.54AM]


select * from [CarData].[GoForte_Extract]
/*
drop table [CarData].[GoForte_Extract];
CREATE TABLE [CarData].[GoForte_Extract]
(
	Listcode		varchar(20)	NOT NULL,
	Appnumber		char(10)	NOT NULL UNIQUE,	-- 99,999,999
	Last			varchar(30)	NULL,
	First			varchar(30)	NULL,
	Middle			char(1)		NULL,
	Address			varchar(50)	NULL,
	City			varchar(30)	NULL,
	State			char(2)		NULL,
	Zip				char(5)		NULL,
	Phone			char(10)	NULL,
	VIN				char(17)	NULL,
	Year			char(4)		NULL,
	Model			varchar(50)	NULL,
	Make			varchar(50)	NULL,
	Odom			varchar(10)	NULL
);
*/



alter table [CarData].[List_002_Clean__2015-03-18_9.54AM] add SNum int identity(1,1)

delete [CarData].[List_002_Clean__2015-03-18_9.54AM_File6]
where Phone_number in (select Phone from [CarData].[SoldPhone])


INSERT [CarData].[List_002_Clean__2015-03-18_9.54AM_File6] (
	[lead_id], [entry_date], [modify_date], [status], [userX], [vendor_lead_code], [source_id], [list_id], [gmt_offset_now], [called_since_last_reset], [phone_code],
	[phone_number], [title], [first_name], [middle_initial], [last_name], [address1], [address2], [address3], [city], [state], [province], [postal_code],
	[country_code], [gender], [date_of_birth], [alt_phone], [email], [security_phrase], [comments], [called_count], [last_local_call_time], [rank],
	[owner], [make], [model], [vin], [year], [Mileage], [custom1] )

SELECT [lead_id], [entry_date], [modify_date], [status], [userX], [vendor_lead_code], [source_id], [list_id], [gmt_offset_now], [called_since_last_reset], [phone_code],
	[phone_number], [title], [first_name], [middle_initial], [last_name], [address1], [address2], [address3], [city], [state], [province], [postal_code],
	[country_code], [gender], [date_of_birth], [alt_phone], [email], [security_phrase], [comments], [called_count], [last_local_call_time], [rank],
	[owner], [make], [model], [vin], [year], [Mileage], [custom1]
FROM [CarData].[List_002_Clean__2015-03-18_9.54AM]
--where SNum between 1 and 83883	-- 1
-- where SNum between 83884 and 167767	-- 2
-- where SNum between 167768 and 251650	-- 3
-- where SNum between 251651 and 335533	-- 4
 --where SNum between 335534 and 419416	-- 5
where SNum > 419416



select status, count(*)
from [QSM].[CarData].[CarData_All]
group by status

create table [CarData].[SoldPhone] (Phone Phone)
select * from [CarData].[SoldPhone]

insert [CarData].[SoldPhone] (Phone)
select distinct phone_number from [QSM].[CarData].[CarData_All] where status = 'SALE'
and phone_number like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'

select count(*) from [CarData].[List_002_Clean__2015-03-18_9.54AM_File6]

truncate table [CarData].[List_002_Clean__2015-03-18_9.54AM_File5]

select 

select count(*) from [CarData].[List_002_Clean__2015-03-18_9.54AM_File1]
select count(*) from [CarData].[List_002_Clean__2015-03-18_9.54AM_File2]
select count(*) from [CarData].[List_002_Clean__2015-03-18_9.54AM_File3]
select count(*) from [CarData].[List_002_Clean__2015-03-18_9.54AM_File4]
select count(*) from [CarData].[List_002_Clean__2015-03-18_9.54AM_File5]
select count(*) from [CarData].[List_002_Clean__2015-03-18_9.54AM_File6]

/*
CREATE TABLE [CarData].[List_002_Clean__2015-03-18_9.54AM_File6](
	[lead_id] [int] NULL,
	[entry_date] [smalldatetime] NULL,
	[modify_date] [smalldatetime] NULL,
	[status] [varchar](50) NULL,
	[userX] [varchar](50) NULL,
	[vendor_lead_code] [varchar](50) NULL,
	[source_id] [varchar](50) NULL,
	[list_id] [varchar](50) NULL,
	[gmt_offset_now] [varchar](50) NULL,
	[called_since_last_reset] [varchar](50) NULL,
	[phone_code] [varchar](50) NULL,
	[phone_number] [varchar](50) NULL,
	[title] [varchar](50) NULL,
	[first_name] [varchar](50) NULL,
	[middle_initial] [varchar](50) NULL,
	[last_name] [varchar](50) NULL,
	[address1] [varchar](100) NULL,
	[address2] [varchar](100) NULL,
	[address3] [varchar](100) NULL,
	[city] [varchar](50) NULL,
	[state] [varchar](50) NULL,
	[province] [varchar](50) NULL,
	[postal_code] [varchar](50) NULL,
	[country_code] [varchar](50) NULL,
	[gender] [varchar](50) NULL,
	[date_of_birth] [varchar](50) NULL,
	[alt_phone] [varchar](50) NULL,
	[email] [varchar](50) NULL,
	[security_phrase] [varchar](100) NULL,
	[comments] [varchar](500) NULL,
	[called_count] [varchar](50) NULL,
	[last_local_call_time] [varchar](50) NULL,
	[rank] [varchar](50) NULL,
	[owner] [varchar](50) NULL,
	[make] [varchar](50) NULL,
	[model] [varchar](50) NULL,
	[vin] [varchar](50) NULL,
	[year] [varchar](50) NULL,
	[Mileage] [varchar](50) NULL,
	[custom1] [varchar](1000) NULL
) ON [PRIMARY]
*/
