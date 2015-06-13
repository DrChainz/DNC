-- select * from [DNC].[WirelessPhoneBlock_BuildLog];
-- exec up_DNC_FileMakeRpt;

IF OBJECT_ID(N'up_MakeWirelessDNC_Tables') IS NOT NULL
	DROP PROC up_MakeWirelessDNC_Tables;
GO

CREATE PROC up_MakeWirelessDNC_Tables
	@UsrRunDt	smalldatetime = NULL
AS

	DECLARE @AreaCd		char(3) = NULL;
	DECLARE @TableName	varchar(30) = NULL;
	DECLARE @SQL		varchar(MAX);
	DECLARE @RunDt		smalldatetime = (SELECT MAX(RunDt) FROM [DNC].[WirelessPhoneBlock_BuildLog]);

	IF (@UsrRunDt IS NOT NULL)
		SET @RunDt = @UsrRunDt;

	DECLARE WirelessAreaCd_Cursor CURSOR FOR
	SELECT AreaCd
	FROM [DNC].[WirelessPhoneBlock_BuildLog]
	WHERE RunDt = @RunDt
	;

	OPEN WirelessAreaCd_Cursor
	FETCH NEXT FROM WirelessAreaCd_Cursor INTO @AreaCd;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @TableName = '[DNC].[WirelessPhone_' + @AreaCd + ']';

		IF OBJECT_ID(@TableName) IS NOT NULL
		BEGIN
			SET @SQL = 'DROP TABLE ' + @TableName + ';';
			EXEC (@SQL);
		END

		SET @SQL = 'CREATE TABLE ' + @TableName + ' (Phone char(10) NOT NULL);' ;

		EXEC (@SQL);

		FETCH NEXT FROM WirelessAreaCd_Cursor INTO @AreaCd;
	END

	CLOSE WirelessAreaCd_Cursor;
	DEALLOCATE WirelessAreaCd_Cursor;
GO

EXEC up_MakeWirelessDNC_Tables;