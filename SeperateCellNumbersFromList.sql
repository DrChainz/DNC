-- select * from [DNC].[WirelessPhoneBlock_BuildLog]
-- [dbo].[up_DNC_FileMakeRpt]
-- select top 1000 * from DNC.WirelessPhone_201
-- select count(*) from DNC.WirelessPhone_202


-- Create table [List].[CarPhone_Cell] (Phone char(10) NOT NULL)
----------------------------------------------------------------------------------------
--
----------------------------------------------------------------------------------------

INSERT [List].[CarPhone_Cell]
SELECT * FROM [List].[CarPhone_Test1]
WHERE substring(Phone,1,7) in (SELECT PhoneBegin FROM [DNC].[WirelessBlocks]);

DELETE [List].[CarPhone_Cell]
WHERE Phone in (SELECT Phone FROM [DNC].[WirelessToLandline]);

INSERT [List].[CarPhone_Cell]
SELECT Phone FROM [List].[CarPhone_Test1]
WHERE Phone IN (SELECT Phone FROM [DNC].[LandlineToWireless]) -- 4,848,769 to remove
  AND Phone NOT IN (SELECT Phone FROM [List].[CarPhone_Cell]);


