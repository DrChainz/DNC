use PrivateReserve
GO

IF OBJECT_ID(N'up_DNC_FileMakeRpt') IS NOT NULL
	DROP PROC up_DNC_FileMakeRpt;
GO

create proc up_DNC_FileMakeRpt
	@UsrRunDt	smalldatetime = NULL
AS
DECLARE @RunDt smalldatetime = (SELECT MAX(RunDt) FROM [DNC].[WirelessPhoneBlock_BuildLog])

IF @UsrRunDt IS NOT NULL
	SET @RunDt = @UsrRunDt;

SELECT	count(*) AreaCodes, sum(Cnt) as TotalCnt, sum(PrefixCnt) TotalPrefixCnt,
		sum(Added_LandlineToWirelessCnt) as TotalAdded_LandlineToWirelessCnt, sum(Removed_WirelessToLandlineCnt) as TotalRemoved_WirelessToLandlineCnt,
		convert(numeric(5,2), convert(float,sum(datediff(mi, StartTm, EndTm)))/60) TotalHours
FROM [DNC].[WirelessPhoneBlock_BuildLog]
WHERE RunDt = @RunDt
  AND EndTm IS NOT NULL
GO

exec up_DNC_FileMakeRpt;
