USE [PrivateReserve]
GO
SET ANSI_NULLS ON
GO
SET ANSI_PADDING ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
CREATE TABLE [DNC].[LandlineToWireless](
	[Phone] [char](10) NULL
) ON [PRIMARY];

CREATE TABLE [DNC].[TmpAreaDNC]
(
	Phone		char(10)		NOT NULL
) ON [PRIMARY];

CREATE TABLE [DNC].[WirelessBlocks]
(
	[NPA]		[char](3)		NOT NULL,
	[NXX]		[char](3)		NOT NULL,
	[X]			[char](1)		NOT NULL,
	[CATEGORY]	[varchar](5)	NOT NULL
) ON [PRIMARY];

-- drop TABLE [DNC].[WirelessPhoneBlock_BuildLog]

CREATE TABLE [DNC].[WirelessPhoneBlock_BuildLog]
(
	RunDt							smalldatetime	NOT NULL,
	AreaCd							char(3)			NOT NULL,
	Cnt								int				NOT NULL,
	PrefixCnt						int				NOT NULL,
	PrefixXCnt						int				NOT NULL,
	Added_LandlineToWirelessCnt		int				NOT NULL,
	Removed_WirelessToLandlineCnt	int				NOT NULL,
	StartTm							smalldatetime	NOT NULL,
	EndTm							smalldatetime	NULL,
	Duration						varchar(10)		NULL
);

CREATE TABLE [DNC].[WirelessToLandline]
(
	[Phone] [char](10) NULL
) ON [PRIMARY];


-------------------------------------------------------------------
--
-------------------------------------------------------------------

*/

/*
EXEC [master].[dbo].sp_configure 'show advanced options',1
RECONFIGURE WITH OVERRIDE
-- GO
EXEC [master].[dbo].sp_configure 'xp_cmdshell',1
RECONFIGURE WITH OVERRIDE
-- GO
*/
IF OBJECT_ID(N'up_DNC_FileMake') IS NOT NULL
	DROP PROC up_DNC_FileMake;
GO

CREATE PROC up_DNC_FileMake
	@UsrRunDt	smalldatetime = NULL
AS
SET NOCOUNT ON;
	
	DECLARE @RunDt		smalldatetime = dateadd(dd, datediff(dd, 0, getdate()), 0);

	IF @UsrRunDt IS NOT NULL
		SET @RunDt = @UsrRunDt;

	DECLARE @AreaCdCnt	int = 0;
	DECLARE @Added_LandlineToWirelessCnt	int = 0;
	DECLARE @Removed_LandlineToWirelessCnt	int = 0;
	DECLARE @StartTm	smalldatetime;
	DECLARE @EndTm		smalldatetime;
	DECLARE @Duration	varchar(10);
	
	DECLARE @AreaCnt	smallint = 0;
	DECLARE @AreaCd		char(3);
	DECLARE @Prefix		char(3);
	DECLARE @X			char(1);
	DECLARE @PrefixCnt	smallint = 0;
	DECLARE @PrefixXCnt	smallint = 0;
	DECLARE @Cnt 		smallint;
	DECLARE @hash_cnt	int = 0;
	DECLARE @bcp_cmd	varchar(100);

	DECLARE @Area TABLE
	(
		Cd		char(3)		NOT NULL,
		Cnt		smallint	NOT NULL
	);

	DECLARE @AreaBlock TABLE
	(
		Prefix	char(3)		NOT NULL,
		X		char(1)		NOT NULL
	);

	DECLARE @AreaDNC TABLE
	(
		Phone	char(10)	NOT NULL
	);

	DECLARE @Add_LandlineToWireless TABLE
	(
		Phone	char(10)	NOT NULL
	);

	DECLARE @Remove_WirelessToLandline TABLE
	(
		Phone	char(10)	NOT NULL
	);

	-- Save some time if already started for the @RunDt and proc gets interupted
	DECLARE @AreaCd_Complete TABLE
	(
		AreaCd	char(3)	NOT NULL
	);

	INSERT @AreaCd_Complete (AreaCd)
	SELECT AreaCd FROM [DNC].[WirelessPhoneBlock_BuildLog]
	WHERE RunDt = @RunDt
	  AND EndTm IS NOT NULL;
	  
	INSERT @Area (Cd, Cnt)
	SELECT NPA, COUNT(*) Cnt
	FROM [DNC].[WirelessBlocks]
	WHERE NPA NOT IN (SELECT AreaCd FROM @AreaCd_Complete)
	GROUP BY NPA;

--	select * from @Area order by Cd;
--  RETURN -1;

	DECLARE AreaCd_Cursor CURSOR FOR
	SELECT Cd, Cnt
	FROM @Area
	ORDER BY Cd;

	OPEN AreaCd_Cursor
	FETCH NEXT FROM AreaCd_Cursor INTO @AreaCd, @Cnt;

	WHILE @@FETCH_STATUS = 0
	BEGIN
 		TRUNCATE TABLE [DNC].[TmpAreaDNC]
		
		SET @AreaCnt += 1;

		RAISEERROR (@AreaCd, 10, 1) WITH NOWAIT;	-- output to result window the AreaCd being worked on.

		SET @AreaCdCnt = 0;
		SET @PrefixCnt = 0;
		SET @PrefixXCnt = 0;

		SET @Removed_LandlineToWirelessCnt = 0;
		SET @Added_LandlineToWirelessCnt = 0;
		SET @StartTm = NULL;
		SET @EndTm = NULL;

		DELETE [DNC].[WirelessPhoneBlock_BuildLog] WHERE RunDt = @RunDt AND AreaCd = @AreaCd;
		SELECT @StartTm = GETDATE();
		INSERT [DNC].[WirelessPhoneBlock_BuildLog] (RunDt, AreaCd, Cnt, PrefixCnt, PrefixXCnt, Added_LandlineToWirelessCnt, Removed_WirelessToLandlineCnt, StartTm, EndTm, Duration)
		VALUES (@RunDt, @AreaCd, @AreaCdCnt, @PrefixCnt, @PrefixXCnt, @Added_LandlineToWirelessCnt, @Removed_LandlineToWirelessCnt, @StartTm, @EndTm, NULL)

		DELETE @Add_LandlineToWireless;
		INSERT @Add_LandlineToWireless (Phone)
		SELECT Phone FROM [DNC].[LandlineToWireless]
		WHERE Phone like @AreaCd + '%'

		DELETE @Remove_WirelessToLandline;
		INSERT @Remove_WirelessToLandline (Phone)
		SELECT Phone FROM [DNC].[WirelessToLandline]
		WHERE Phone like @AreaCd + '%'
		
		DELETE @AreaBlock;
 		INSERT @AreaBlock (Prefix, X)
		SELECT NXX, X
		FROM [DNC].[WirelessBlocks]
		WHERE NPA = @AreaCd
 		ORDER BY NXX, X;

		SET @PrefixXCnt = 0;

		DECLARE Prefix_Cursor CURSOR FOR
		SELECT Prefix, X
		FROM @AreaBlock
		ORDER BY Prefix, X;

		OPEN Prefix_Cursor
		FETCH NEXT FROM Prefix_Cursor INTO @Prefix, @X;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @PrefixXCnt += 1;

			SET @hash_cnt = 0;
			WHILE(@hash_cnt <= 999)
			BEGIN
				INSERT [DNC].[TmpAreaDNC] (Phone)
				SELECT @AreaCd + @Prefix + @X + RIGHT('000'+CAST(@hash_cnt AS VARCHAR(3)),3);
				SET @hash_cnt += 1;
			END

			FETCH NEXT FROM Prefix_Cursor INTO @Prefix, @X;
		END

		CLOSE Prefix_Cursor;
		DEALLOCATE Prefix_Cursor;
		
		SELECT @Removed_LandlineToWirelessCnt = COUNT(*) FROM [PrivateReserve].[DNC].[TmpAreaDNC]
														 WHERE Phone IN (SELECT Phone FROM @Remove_WirelessToLandline);

		DELETE [DNC].[TmpAreaDNC] WHERE Phone IN (SELECT Phone FROM @Remove_WirelessToLandline);

		DELETE @Add_LandlineToWireless WHERE Phone IN (SELECT Phone FROM [PrivateReserve].[DNC].[TmpAreaDNC]);

		SELECT @Added_LandlineToWirelessCnt = COUNT(*) FROM @Add_LandlineToWireless
													   WHERE Phone NOT IN (SELECT Phone FROM [PrivateReserve].[DNC].[TmpAreaDNC]);
		
		INSERT [PrivateReserve].[DNC].[TmpAreaDNC] (Phone)
		SELECT DISTINCT Phone FROM @Add_LandlineToWireless;

		SELECT @AreaCdCnt = COUNT(*) FROM [PrivateReserve].[DNC].[TmpAreaDNC];

		SELECT @PrefixCnt = COUNT(DISTINCT NXX) FROM [DNC].[WirelessBlocks] WHERE NPA = @AreaCd;

		SELECT @EndTm = GETDATE();

		SELECT @Duration = convert(varchar(5),DateDiff(s, @StartTm, @EndTm)/3600)+':'+convert(varchar(5),DateDiff(s, @StartTm, @EndTm)%3600/60)+':'+convert(varchar(5),(DateDiff(s, @StartTm, @EndTm)%60)); -- as [hh:mm:ss]

		UPDATE [DNC].[WirelessPhoneBlock_BuildLog]
			SET Cnt = @AreaCdCnt,
				PrefixCnt = @PrefixCnt,
				PrefixXCnt = @PrefixXCnt,
				Added_LandlineToWirelessCnt = @Added_LandlineToWirelessCnt,
				Removed_WirelessToLandlineCnt = @Removed_LandlineToWirelessCnt,
				EndTm = @EndTm,
				Duration = @Duration
		WHERE RunDt = @RunDt
		  AND AreaCd = @AreaCd;

 		SET @bcp_cmd = 'bcp PrivateReserve.DNC.TmpAreaDNC out "C:\DNC\' + @AreaCd + '.txt" -T -c';
  		EXEC xp_cmdshell  @bcp_cmd, no_output;

		FETCH NEXT FROM AreaCd_Cursor INTO @AreaCd, @Cnt;
	END

	CLOSE AreaCd_Cursor;
	DEALLOCATE AreaCd_Cursor;
GO

exec up_DNC_FileMake;