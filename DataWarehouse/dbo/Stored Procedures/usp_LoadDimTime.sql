
CREATE PROCEDURE [dbo].[usp_LoadDimTime]
	@BeginTime					DATETIME = '1/1/1900 00:00',
	@EndTime					DATETIME = '1/1/1900 23:59',
	@InsertUnknownTimeRecord	BIT = 1
AS
BEGIN
	--
	--Stored proc useed to populate the date dimension table
	--
	SET NOCOUNT ON;
	
	--
	--Parameter validation and error handling
	--
	IF @BeginTime IS NULL
		RAISERROR ('BeginTime parameter must be passed into [usp_LoadDimTime]', 16, 1) WITH NOWAIT;
	IF @EndTime IS NULL
		RAISERROR ('EndTime parameter must be passed into [usp_LoadDimTime]', 16, 1) WITH NOWAIT;
	IF @BeginTime >= @EndTime
		RAISERROR ('BeginTime parameter must be less than EndTime parameter', 16, 1) WITH NOWAIT;


	WHILE (@BeginTime <= @EndTime)
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM [dbo].[DimTime] WHERE [Time] = CAST(@BeginTime AS TIME)) 
		BEGIN
			INSERT INTO [dbo].[DimTime] (
				[TimeKey],
				[Time],
				[HourNumber],
				[HourNameLong],
				[HourNameShort],
				[MinuteNumber],
				[MinuteNameLong],
				[MinuteNameShort],
				[TimeNameStandard],
				[TimeNameMilitary],
				[IsUnknownTime]
			)
			VALUES (
				CAST(FORMAT(@BeginTime,'HHmm') AS INT),						--[TimeKey]
				CAST(@BeginTime AS TIME),									--[Time]
				CAST(DATEPART(HOUR, @BeginTime) AS TINYINT),				--[HourNumber]
				'Hour ' + FORMAT(DATEPART(HOUR, @BeginTime), '00'),			--[HourNameLong]
				FORMAT(DATEPART(HOUR, @BeginTime), '00'),					--[HourNameShort]
				CAST(DATEPART(MINUTE, @BeginTime) AS TINYINT),				--[MinuteNumber]
				'Minute ' + FORMAT(DATEPART(MINUTE, @BeginTime), '00'),		--[MinuteNameLong]
				FORMAT(DATEPART(MINUTE, @BeginTime), '00'),					--[MinuteNameShort]
				--
				FORMAT(CASE ((DATEPART(HOUR, @BeginTime) % 12)) WHEN 0 THEN 12 ELSE ((DATEPART(HOUR, @BeginTime) % 12)) END, '00') + 
					':' + 
					 FORMAT(DATEPART(MINUTE, @BeginTime), '00') +
					':00',													--[TimeNameStandard]
				--
				FORMAT(DATEPART(HOUR, @BeginTime), '00') + 
					 ':' + 
					 FORMAT(DATEPART(MINUTE, @BeginTime), '00') +
					 ':00',													--[TimeNameMilitary]
				--
				0															--[IsUnknownTime]
			);
		END;

		--
		--Add 1 minute to @BeginTime
		--
		SET @BeginTime = DATEADD(MINUTE, 1, @BeginTime)
	END;

	--
	--Insert a record for our Unknown Time
	--
	IF @InsertUnknownTimeRecord = 1 AND NOT EXISTS (SELECT 1 FROM [dbo].[DimTime] WHERE [TimeKey] = -1) 
	BEGIN
			INSERT INTO [dbo].[DimTime] (
				[TimeKey],
				[Time],
				[HourNumber],
				[HourNameLong],
				[HourNameShort],
				[MinuteNumber],
				[MinuteNameLong],
				[MinuteNameShort],
				[TimeNameStandard],
				[TimeNameMilitary],
				[IsUnknownTime]
			)
			VALUES (
				-1,															--[TimeKey]
				NULL,														--[Time]
				-1,															--[HourNumber]
				'Unknown',													--[HourNameLong]
				'Unknown',													--[HourNameShort]
				-1,															--[MinuteNumber]
				'Unknown',													--[MinuteNameLong]
				'Unknown',													--[MinuteNameShort]
				'Unknown',													--[TimeNameStandard]
				'Unknown',													--[TimeNameMilitary]
				1															--[IsUnknownTime]
			);
	END;
END;