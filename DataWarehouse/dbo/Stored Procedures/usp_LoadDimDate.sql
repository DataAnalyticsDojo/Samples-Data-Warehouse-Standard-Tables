
CREATE PROCEDURE [dbo].[usp_LoadDimDate]
	@BeginDate			DATE,
	@EndDate			DATE,
	@FiscalMonthStart	SMALLINT = 1,
	@UnknownRecordDate  DATE = '12/31/1899'
AS
BEGIN
	--
	--Stored proc useed to populate the date dimension table
	--All the dates between begin and end date will be loaded into DimDate
	--Additionally, a date to be used for the "Unknown" date of 1/1/1900 is loaded as well
	--This proc assumes that if the fiscal month start is 1, then your fiscal calendar follows the calendar year.
	--Any other month assumes the fiscal year starts on the first day of the specified month
	--
	SET NOCOUNT ON;

	--
	--Parameter validation and error handling
	--
	IF @BeginDate IS NULL
		RAISERROR ('BeginDate parameter must be passed into [usp_LoadDimDate]', 16, 1) WITH NOWAIT;
	IF @EndDate IS NULL
		RAISERROR ('EndDate parameter must be passed into [usp_LoadDimDate]', 16, 1) WITH NOWAIT;
	IF @BeginDate >= @EndDate
		RAISERROR ('BeginDate parameter must be less than EndDate parameter', 16, 1) WITH NOWAIT;
	IF @FiscalMonthStart < 1 OR @FiscalMonthStart > 12
		RAISERROR ('FiscalMonthStart parameter must be between 1 and 12', 16, 1) WITH NOWAIT;


	WHILE (@BeginDate <= @EndDate)
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM [dbo].[DimDate] WHERE [Date] = @BeginDate) 
		BEGIN
			--
			--Set calculated fields for calendar and fiscal year info
			--
			DECLARE @FiscalYearNumber			SMALLINT,
					@FirstDateOfFiscalYear		DATE,
					@LastDateOfFiscalYear		DATE,
					@FirstDateOfCalendarYear	DATE,
					@LastDateOfCalendarYear		DATE,
					@FirstDateOfWeek			DATE,
					@LastDateOfWeek				DATE,
					@FirstDateOfCalendarQuarter	DATE,
					@LastDateOfCalendarQuarter	DATE,
					@CalendarQuarterNumber      SMALLINT,
					@CalendarMonthNumber		SMALLINT,
					@FiscalMonthNumber			SMALLINT,
					@FiscalQuarterNumber		SMALLINT,
					@FirstDateOfFiscalQuarter	DATE,
					@LastDateOfFiscalQuarter	DATE;			

			SET @FirstDateOfCalendarYear = DATEFROMPARTS(YEAR(@BeginDate), 1, 1);
			SET @LastDateOfCalendarYear = DATEFROMPARTS(YEAR(@BeginDate), 12, 31);
			SET @FirstDateOfWeek = DATEADD(WEEK, DATEDIFF(WEEK, 0, @BeginDate), -1); --Sunday
			SET @LastDateOfWeek = DATEADD(DAY, 6, @FirstDateOfWeek); --Saturday
			SET @FirstDateOfCalendarQuarter = DATEADD(qq, DATEDIFF(qq, 0, @BeginDate), 0);
			SET @LastDateOfCalendarQuarter = DATEADD (dd, -1, DATEADD(qq, DATEDIFF(qq, 0, @BeginDate) +1, 0));
			SET @CalendarQuarterNumber = DATEPART(QUARTER,  @BeginDate);
			SET @CalendarMonthNumber = DATEPART(MONTH,    @BeginDate);

			--
			--Set the fiscal year
			--
			--Fiscal year is different from calendar year
			IF @FiscalMonthStart > 1 AND DATEPART(MONTH, @BeginDate) >= @FiscalMonthStart
			BEGIN
				SET @FiscalYearNumber = DATEPART(YEAR, @BeginDate) + 1;
			END
			--Fiscal year is same as calendar year
			ELSE 
			BEGIN
				SET @FiscalYearNumber = DATEPART(YEAR, @BeginDate) ;
			END

			--
			--Set the fiscal start/end dates
			--If we have a fiscal year starting in a different month from the calendar start of year
			--The compute the FY start and end dates
			--
			IF @FiscalMonthStart > 1 
			BEGIN
				SET @FirstDateOfFiscalYear = DATEFROMPARTS(@FiscalYearNumber - 1, @FiscalMonthStart, 1);
				SET @LastDateOfFiscalYear = DATEADD(DAY, -1, DATEFROMPARTS(@FiscalYearNumber, @FiscalMonthStart, 1));
				SET @FiscalMonthNumber = DATEDIFF(MONTH, @FirstDateOfFiscalYear, @BeginDate) + 1;
				SET @FiscalQuarterNumber = (CASE 
											WHEN @FiscalMonthNumber IN (1, 2, 3) THEN 1 
											WHEN @FiscalMonthNumber IN (4, 5, 6) THEN 2
											WHEN @FiscalMonthNumber IN (7, 8, 9) THEN 3
											WHEN @FiscalMonthNumber IN (10, 11, 12) THEN 4
											END);
				--TODO
				SET @FirstDateOfFiscalQuarter = @FirstDateOfCalendarQuarter;
				SET @LastDateOfFiscalQuarter = @LastDateOfCalendarQuarter;
			END
			--
			--Otherwise the FY start and end dates are simply the same as the calendar year
			--
			ELSE
			BEGIN
				SET @FirstDateOfFiscalYear = @FirstDateOfCalendarYear;
				SET @LastDateOfFiscalYear = @LastDateOfCalendarYear;
				SET @FiscalMonthNumber = @CalendarMonthNumber;
				SET @FiscalQuarterNumber = @CalendarQuarterNumber;
				SET @FirstDateOfFiscalQuarter = @FirstDateOfCalendarQuarter;
				SET @LastDateOfFiscalQuarter = @LastDateOfCalendarQuarter;

			END;

			--
			--Insert the dates
			--
			INSERT INTO [dbo].[DimDate] (
				[DateKey],
				[Date],
				--Components by Calendar Year	
				[CalendarYearNumber],
				[CalendarWeekNumber],
				[CalendarISOWeekNumber],
				[CalendarQuarterNumber],
				[CalendarMonthNumber],
				[CalendarDayOfYear],
				--Components by Fiscal Year	
				[FiscalYearNumber],
				[FiscalWeekNumber],
				[FiscalQuarterNumber],
				[FiscalMonthNumber],
				[FiscalDayOfYear],
				--Calendar Offsets
				[CalendarYearOffsetFromToday],
				[CalendarQuarterOffsetFromToday],
				[CalendarMonthOffsetFromToday],
				[CalendarWeekOffsetFromToday],
				[CalendarDayOffsetFromToday],
				--Fiscal Offsets
				[FiscalYearOffsetFromToday],
				[FiscalQuarterOffsetFromToday],
				[FiscalMonthOffsetFromToday],
				[FiscalWeekOffsetFromToday],
				[FiscalDayOffsetFromToday],
				--Calendar Year Info
				[FirstDateOfCalendarYear],
				[LastDateOfCalendarYear],
				[NumDaysInCalendarYear],
				[NumBusinessDaysInCalendarYear],
				[CalendarYearNameLong],
				[CalendarYearNameShort],
				--Fiscal Year Info
				[FirstDateOfFiscalYear],
				[LastDateOfFiscalYear],
				[NumDaysInFiscalYear],
				[NumBusinessDaysInFiscalYear],
				[FiscalYearNameLong],
				[FiscalYearNameShort],
				--Week Info
				[FirstDateOfWeek],
				[LastDateOfWeek],
				[NumDaysInWeek],
				[NumBusinessDaysInWeek],
				[WeekNameLong],
				[WeekNameShort],
				--Calendar Quarter Info
				[FirstDateOfCalendarQuarter],
				[LastDateOfCalendarQuarter],
				[NumDaysInCalendarQuarter],
				[NumBusinessDaysInCalendarQuarter],
				[CalendarQuarterNameLong],
				[CalendarQuarterNameShort],
				[CalendarQuarterAndYearNameLong],
				[CalendarQuarterAndYearNameShort],
				--Fiscal Quarter Info
				[FirstDateOfFiscalQuarter],
				[LastDateOfFiscalQuarter],
				[NumDaysInFiscalQuarter],
				[NumBusinessDaysInFiscalQuarter],
				[FiscalQuarterNameLong],
				[FiscalQuarterNameShort],
				[FiscalQuarterAndYearNameLong],
				[FiscalQuarterAndYearNameShort],
				--Month Info
				[FirstDateOfMonth],
				[LastDateOfMonth],
				[NumDaysInMonth],
				[NumBusinessDaysInMonth],
				[MonthNameLong],
				[MonthNameShort],
				--Day Info
				[DayOfWeek],
				[DayOfMonth],
				[DayNameLong],
				[DayNameShort], 
				[DayFullNameLong],
				[DayFullNameShort],
				--Flags
				[IsFutureDate],
				[IsUnknownDate],
				[IsWeekend],
				[IsHoliday],
				[HolidayName],
				[IsBusinessDay],
				[IsFirstDayOfCalendarYear],
				[IsLastDayOfCalendarYear],
				[IsFirstDayOfFiscalYear],
				[IsLastDayOfFiscalYear],
				[IsCurrentCalendarYear],
				[IsCurrentFiscalYear],
				[IsCurrentCalendarQuarter],
				[IsCurrentFiscalQuarter],
				[IsCurrentMonth],
				[IsCurrentWeek],
				[IsToday]
			)
			VALUES (
				CAST(FORMAT(@BeginDate,'yyyyMMdd') AS INT),					--[DateKey]
				@BeginDate,													--[Date]
				--Components by Calendar Year	
				DATEPART(YEAR,     @BeginDate),								--[CalendarYearNumber]
				DATEPART(WEEK,     @BeginDate),								--[CalendarWeekNumber]
				DATEPART(ISO_WEEK, @BeginDate),								--[CalendarISOWeekNumber]
				@CalendarQuarterNumber,										--[CalendarQuarterNumber]
				@CalendarMonthNumber,										--[CalendarMonthNumber]
				DATEPART(DAYOFYEAR,@BeginDate),								--[CalendarDayOfYear]
				--Components by Fiscal Year	
				--If the fiscal month start is not january, then we take any month greater than or equal to the
				--fiscal month start and set its fiscal year to the following year.
				--So fiscal month start of 6 (june) means all Jan-May dates fiscal year is the date's year,
				--and all jun-dev dates fiscal year is the next year for the date
				@FiscalYearNumber,											--[FiscalYearNumber]
				DATEDIFF(WEEK, @FirstDateOfFiscalYear, @BeginDate) + 1,		--[FiscalWeekNumber]
				@FiscalQuarterNumber,										--[FiscalQuarterNumber]
				@FiscalMonthNumber,											--[FiscalMonthNumber]
				DATEDIFF(DAY, @FirstDateOfFiscalYear, @BeginDate) + 1,		--[FiscalDayOfYear]
				--Calendar Offsets
			    0,															--[CalendarYearOffsetFromToday]
			    0,															--[CalendarQuarterOffsetFromToday]
			    0,															--[CalendarMonthOffsetFromToday]
			    0,															--[CalendarWeekOffsetFromToday]
			    0,															--[CalendarDayOffsetFromToday]
				--Fiscal Offsets
				0,															--[FiscalYearOffsetFromToday]
				0,															--[FiscalQuarterOffsetFromToday]
				0,															--[FiscalMonthOffsetFromToday]
				0,															--[FiscalWeekOffsetFromToday]
				0,															--[FiscalDayOffsetFromToday]
				--Calendar Year Info
				@FirstDateOfCalendarYear,									--[FirstDateOfCalendarYear]
				@LastDateOfCalendarYear,									--[LastDateOfCalendarYear]
				DATEDIFF(dd, @FirstDateOfCalendarYear, @LastDateOfCalendarYear) + 1, --[NumDaysInCalendarYear]
				0,															--[NumBusinessDaysInCalendarYear]
				'CY' + DATENAME(YEAR, @BeginDate),							--[CalendarYearNameLong]
				'CY' + RIGHT(DATENAME(YEAR, @BeginDate), 2),				--[CalendarYearNameShort]
				--Fiscal Year Info
				@FirstDateOfFiscalYear,										--[FirstDateOfFiscalYear]
				@LastDateOfFiscalYear,										--[LastDateOfFiscalYear]
				DATEDIFF(dd, @FirstDateOfFiscalYear, @LastDateOfFiscalYear) + 1, --[NumDaysInFiscalYear]
				0,															--[NumBusinessDaysInFiscalYear]
				'FY' + CAST(@FiscalYearNumber AS VARCHAR(4)),				--[FiscalYearNameLong]
				'FY' + RIGHT(CAST(@FiscalYearNumber AS VARCHAR(4)), 2),		--[FiscalYearNameShort]
				--Week Info
				@FirstDateOfWeek,											--[FirstDateOfWeek]
				@LastDateOfWeek,											--[LastDateOfWeek],
				7,															--[NumDaysInWeek]
				0,															--[NumBusinessDaysInWeek]
				DATENAME(WEEKDAY, @FirstDateOfWeek) + N', ' + DATENAME(MONTH, @FirstDateOfWeek) + N' ' + DATENAME(DAY, @FirstDateOfWeek) + N' ' + DATENAME(YEAR, @FirstDateOfWeek),							--[WeekNameLong],
				LEFT(DATENAME(WEEKDAY, @FirstDateOfWeek), 3) + N', ' + LEFT(DATENAME(MONTH, @FirstDateOfWeek), 3) + N' ' + DATENAME(DAY, @FirstDateOfWeek) + N' ' + DATENAME(YEAR, @FirstDateOfWeek),		--[WeekNameShort]
				--Calendar Quarter Info
				@FirstDateOfCalendarQuarter,								--[FirstDateOfCalendarQuarter]
				@LastDateOfCalendarQuarter,									--[LastDateOfCalendarQuarter],
				DATEDIFF(dd, @FirstDateOfCalendarQuarter, @LastDateOfCalendarQuarter) + 1,		--[NumDaysInCalendarQuarter]
				0,															--[NumBusinessDaysInCalendarQuarter],
				N'Quarter ' + CAST(@CalendarQuarterNumber AS VARCHAR),		-- [CalendarQuarterNameLong]
				N'Q' + CAST(@CalendarQuarterNumber AS VARCHAR),				-- [CalendarQuarterNameShort]
				N'Quarter ' + CAST(@CalendarQuarterNumber AS VARCHAR) + N', ' + CAST(DATEPART(YEAR, @BeginDate) AS VARCHAR), --[CalendarQuarterAndYearNameLong]
				N'Q' + CAST(@CalendarQuarterNumber AS VARCHAR) + N', ' + CAST(DATEPART(YEAR, @BeginDate) AS VARCHAR), --[CalendarQuarterAndYearNameShort]
				--Fiscal Quarter Info
				@FirstDateOfFiscalQuarter,									--[FirstDateOfFiscalQuarter]
				@LastDateOfFiscalQuarter,									--[LastDateOfFiscalQuarter]
				DATEDIFF(dd, @FirstDateOfFiscalQuarter, @LastDateOfFiscalQuarter) + 1,		--[NumDaysInFiscalQuarter]
				0,															--[NumBusinessDaysInFiscalQuarter]
				N'Quarter ' + CAST(@FiscalQuarterNumber AS VARCHAR),		-- [FiscalQuarterNameLong]
				N'Q' + CAST(@FiscalQuarterNumber AS VARCHAR),				-- [FiscalQuarterNameShort]
				N'Quarter ' + CAST(@FiscalQuarterNumber AS VARCHAR) + N', ' + CAST(@FiscalYearNumber AS VARCHAR), --[FiscalQuarterAndYearNameLong]
				N'Q' + CAST(@FiscalQuarterNumber AS VARCHAR) + N', ' + CAST(@FiscalYearNumber AS VARCHAR), --[FiscalQuarterAndYearNameShort]
				--Month Info
				DATEADD(DAY, 1, EOMONTH(@BeginDate, -1)),					--[FirstDateOfMonth]
				EOMONTH (@BeginDate),										--[LastDateOfMonth]
				DAY(EOMONTH(GETDATE())),									--[NumDaysInMonth]
				0,															--[NumBusinessDaysInMonth]
				DATENAME(MONTH, @BeginDate),								--[MonthNameLong]
				SUBSTRING(DATENAME(MONTH, @BeginDate), 1, 3),				--[MonthNameShort]
				--Day Info
				DATEPART(WEEKDAY, @BeginDate),								--[DayOfWeek]
				DATEPART(DAY,     @BeginDate),								--[DayOfMonth]
				DATENAME(WEEKDAY, @BeginDate),								--[DayNameLong]
				SUBSTRING(DATENAME(WEEKDAY, @BeginDate), 1, 3),				--[DayNameShort]
				DATENAME(WEEKDAY, @BeginDate) + N', ' + DATENAME(MONTH, @BeginDate) + N' ' + DATENAME(DAY, @BeginDate) + N' ' + DATENAME(YEAR, @BeginDate),							--[DayFullNameLong],
				LEFT(DATENAME(WEEKDAY, @BeginDate), 3) + N', ' + LEFT(DATENAME(MONTH, @BeginDate), 3) + N' ' + DATENAME(DAY, @BeginDate) + N' ' + DATENAME(YEAR, @BeginDate),		--[DayFullNameShort]
				--Flags
				0,															--[IsFutureDate]
				0,															--[IsUnknownDate]
				CONVERT(BIT, CASE WHEN DATEPART(WEEKDAY, @BeginDate) IN (1,7) THEN 1 ELSE 0 END),	--[IsWeekend]
				0,															--[IsHoliday]
				0,															--[HolidayName]
				0,															--[IsBusinessDay]
				CONVERT(BIT, CASE WHEN @BeginDate = @FirstDateOfCalendarYear THEN 1 ELSE 0 END),	--[IsFirstDayOfCalendarYear]
				CONVERT(BIT, CASE WHEN @BeginDate = @LastDateOfCalendarYear THEN 1 ELSE 0 END),		--[IsLastDayOfCalendarYear]
				CONVERT(BIT, CASE WHEN @BeginDate = @FirstDateOfFiscalYear THEN 1 ELSE 0 END),		--[IsFirstDayOfFiscalYear]
				CONVERT(BIT, CASE WHEN @BeginDate = @LastDateOfFiscalYear THEN 1 ELSE 0 END),		--[IsLastDayOfFiscalYear]
				0,															--[IsCurrentCalendarYear]
				0,															--[IsCurrentFiscalYear]
				0,															--[IsCurrentCalendarQuarter]
				0,															--[IsCurrentFiscalQuarter]
				0,															--[IsCurrentMonth]
				0,															--[IsCurrentWeek]
				CONVERT(BIT, CASE WHEN CAST(GETDATE() AS DATE) = @BeginDate THEN 1 ELSE 0 END)		--[IsToday]
			);
		END;

		--
		--Add 1 day to BeginDate
		--
		SET @BeginDate = DATEADD(dd, 1, @BeginDate)
	END;

	--
	--Insert a record for our Unknown Date
	--
	IF @UnknownRecordDate IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[DimDate] WHERE [Date] = @UnknownRecordDate) 
	BEGIN
			INSERT INTO [dbo].[DimDate] (
				[DateKey],
				[Date],
				--Components by Calendar Year	
				[CalendarYearNumber],
				[CalendarWeekNumber],
				[CalendarISOWeekNumber],
				[CalendarQuarterNumber],
				[CalendarMonthNumber],
				[CalendarDayOfYear],
				--Components by Fiscal Year	
				[FiscalYearNumber],
				[FiscalWeekNumber],
				[FiscalQuarterNumber],
				[FiscalMonthNumber],
				[FiscalDayOfYear],
				--Calendar Offsets
				[CalendarYearOffsetFromToday],
				[CalendarQuarterOffsetFromToday],
				[CalendarMonthOffsetFromToday],
				[CalendarWeekOffsetFromToday],
				[CalendarDayOffsetFromToday],
				--Fiscal Offsets
				[FiscalYearOffsetFromToday],
				[FiscalQuarterOffsetFromToday],
				[FiscalMonthOffsetFromToday],
				[FiscalWeekOffsetFromToday],
				[FiscalDayOffsetFromToday],
				--Calendar Year Info
				[FirstDateOfCalendarYear],
				[LastDateOfCalendarYear],
				[NumDaysInCalendarYear],
				[NumBusinessDaysInCalendarYear],
				[CalendarYearNameLong],
				[CalendarYearNameShort],
				--Fiscal Year Info
				[FirstDateOfFiscalYear],
				[LastDateOfFiscalYear],
				[NumDaysInFiscalYear],
				[NumBusinessDaysInFiscalYear],
				[FiscalYearNameLong],
				[FiscalYearNameShort],
				--Week Info
				[FirstDateOfWeek],
				[LastDateOfWeek],
				[NumDaysInWeek],
				[NumBusinessDaysInWeek],
				[WeekNameLong],
				[WeekNameShort],
				--Calendar Quarter Info
				[FirstDateOfCalendarQuarter],
				[LastDateOfCalendarQuarter],
				[NumDaysInCalendarQuarter],
				[NumBusinessDaysInCalendarQuarter],
				[CalendarQuarterNameLong],
				[CalendarQuarterNameShort],
				[CalendarQuarterAndYearNameLong],
				[CalendarQuarterAndYearNameShort],
				--Fiscal Quarter Info
				[FirstDateOfFiscalQuarter],
				[LastDateOfFiscalQuarter],
				[NumDaysInFiscalQuarter],
				[NumBusinessDaysInFiscalQuarter],
				[FiscalQuarterNameLong],
				[FiscalQuarterNameShort],
				[FiscalQuarterAndYearNameLong],
				[FiscalQuarterAndYearNameShort],
				--Month Info
				[FirstDateOfMonth],
				[LastDateOfMonth],
				[NumDaysInMonth],
				[NumBusinessDaysInMonth],
				[MonthNameLong],
				[MonthNameShort],
				--Day Info
				[DayOfWeek],
				[DayOfMonth],
				[DayNameLong],
				[DayNameShort], 
				[DayFullNameLong],
				[DayFullNameShort],
				--Flags
				[IsFutureDate],
				[IsUnknownDate],
				[IsWeekend],
				[IsHoliday],
				[HolidayName],
				[IsBusinessDay],
				[IsFirstDayOfCalendarYear],
				[IsLastDayOfCalendarYear],
				[IsFirstDayOfFiscalYear],
				[IsLastDayOfFiscalYear],
				[IsCurrentCalendarYear],
				[IsCurrentFiscalYear],
				[IsCurrentCalendarQuarter],
				[IsCurrentFiscalQuarter],
				[IsCurrentMonth],
				[IsCurrentWeek],
				[IsToday]
			)
			VALUES (
				CAST(FORMAT(@UnknownRecordDate,'yyyyMMdd') AS INT),			--[DateKey]
				@UnknownRecordDate,											--[Date]
				--Components by Calendar Year	
				-1,															--[CalendarYearNumber]
				-1,															--[CalendarWeekNumber]
				-1,															--[CalendarISOWeekNumber]
				-1,															--[CalendarQuarterNumber]
				-1,															--[CalendarMonthNumber]
				-1,															--[CalendarDayOfYear]
				--Components by Fiscal Year	
				-1,															--[FiscalYearNumber]
				-1,															--[FiscalWeekNumber]
				-1,															--[FiscalQuarterNumber]
				-1,															--[FiscalMonthNumber]
				-1,															--[FiscalDayOfYear]
				--Calendar Offsets
			    -99999,														--[CalendarYearOffsetFromToday]
			    -99999,														--[CalendarQuarterOffsetFromToday]
			    -99999,														--[CalendarMonthOffsetFromToday]
			    -99999,														--[CalendarWeekOffsetFromToday]
			    -99999,														--[CalendarDayOffsetFromToday]
				--Fiscal Offsets
				-99999,														--[FiscalYearOffsetFromToday]
				-99999,														--[FiscalQuarterOffsetFromToday]
				-99999,														--[FiscalMonthOffsetFromToday]
				-99999,														--[FiscalWeekOffsetFromToday]
				-99999,														--[FiscalDayOffsetFromToday]
				--Calendar Year Info
				@UnknownRecordDate,											--[FirstDateOfCalendarYear]
				@UnknownRecordDate,											--[LastDateOfCalendarYear]
				-1,															--[NumDaysInCalendarYear]
				-1,															--[NumBusinessDaysInCalendarYear]
				'Unknown',													--[CalendarYearNameLong]
				'Unknown',													--[CalendarYearNameShort]
				--Fiscal Year Info
				@UnknownRecordDate,											--[FirstDateOfFiscalYear]
				@UnknownRecordDate,											--[LastDateOfFiscalYear]
				-1,															--[NumDaysInFiscalYear]
				-1,															--[NumBusinessDaysInFiscalYear]
				'Unknown',													--[FiscalYearNameLong]
				'Unknown',													--[FiscalYearNameShort]
				--Week Info
				@UnknownRecordDate,											--[FirstDateOfWeek]
				@UnknownRecordDate,											--[LastDateOfWeek],
				-1,															--[NumDaysInWeek]
				-1,															--[NumBusinessDaysInWeek]
				'Unknown',													--[WeekNameLong],
				'Unknown',													--[WeekNameShort]
				--Calendar Quarter Info
				@UnknownRecordDate,											--[FirstDateOfCalendarQuarter]
				@UnknownRecordDate,											--[LastDateOfCalendarQuarter],
				-1,															--[NumDaysInCalendarQuarter]
				-1,															--[NumBusinessDaysInCalendarQuarter],
				'Unknown',													--[CalendarQuarterNameLong]
				'Unknown',													--[CalendarQuarterNameShort]
				'Unknown',													--[CalendarQuarterAndYearNameLong]
				'Unknown',													--[CalendarQuarterAndYearNameShort]
				--Fiscal Quarter Info
				@UnknownRecordDate,											--[FirstDateOfFiscalQuarter]
				@UnknownRecordDate,											--[LastDateOfFiscalQuarter]
				-1,															--[NumDaysInFiscalQuarter]
				-1,															--[NumBusinessDaysInFiscalQuarter]
				'Unknown',													--[FiscalQuarterNameLong]
				'Unknown',													--[FiscalQuarterNameShort]
				'Unknown',													--[FiscalQuarterAndYearNameLong]
				'Unknown',													--[FiscalQuarterAndYearNameShort]
				--Month Info
				@UnknownRecordDate,											--[FirstDateOfMonth]
				@UnknownRecordDate,											--[LastDateOfMonth]
				-1,															--[NumDaysInMonth]
				-1,															--[NumBusinessDaysInMonth]
				'Unknown',													--[MonthNameLong]
				'Unknown',													--[MonthNameShort]
				--Day Info
				-1,															--[DayOfWeek]
				-1,															--[DayOfMonth]
				'Unknown',													--[DayNameLong]
				'Unk',														--[DayNameShort]
				'Unknown',													--[DayFullNameLong],
				'Unknown',													--[DayFullNameShort]
				--Flags
				0,															--[IsFutureDate]
				1,															--[IsUnknownDate]
				0,															--[IsWeekend]
				0,															--[IsHoliday]
				0,															--[HolidayName]
				0,															--[IsBusinessDay]
				0,															--[IsFirstDayOfCalendarYear]
				0,															--[IsLastDayOfCalendarYear]
				0,															--[IsFirstDayOfFiscalYear]
				0,															--[IsLastDayOfFiscalYear]
				0,															--[IsCurrentCalendarYear]
				0,															--[IsCurrentFiscalYear]
				0,															--[IsCurrentCalendarQuarter]
				0,															--[IsCurrentFiscalQuarter]
				0,															--[IsCurrentMonth]
				0,															--[IsCurrentWeek]
				0															--[IsToday]
			);
	END;


	--
	--Mass updates on these columns since they change every day
	--
	DECLARE @CurrentFiscalYear SMALLINT,
			@CurrentFiscalQuarter SMALLINT;
	SELECT @CurrentFiscalYear = FiscalYearNumber,
	       @CurrentFiscalQuarter = FiscalQuarterNumber
	FROM DimDate WHERE [Date] = CAST(GETDATE() AS DATE);

	UPDATE [dbo].[DimDate]
	SET
		--Calendar Offsets
		[CalendarYearOffsetFromToday] = DATEDIFF(YEAR, GETDATE(), [DimDate].[Date]),
		[CalendarQuarterOffsetFromToday] = DATEDIFF(QUARTER, GETDATE(), [DimDate].[Date]),
		[CalendarMonthOffsetFromToday] = DATEDIFF(MONTH, GETDATE(), [DimDate].[Date]),
		[CalendarWeekOffsetFromToday] = DATEDIFF(WEEK, GETDATE(), [DimDate].[Date]),
		[CalendarDayOffsetFromToday] = DATEDIFF(DAY, GETDATE(), [DimDate].[Date]),
		--Fiscal Offsets
		[FiscalYearOffsetFromToday] = ([DimDate].FiscalYearNumber - @CurrentFiscalYear),
		--Multiple fiscal year difference by 4, and then add the fiscal quarter minus the current fiscal quarter
		[FiscalQuarterOffsetFromToday] = ((FiscalYearNumber - @CurrentFiscalYear) * 4) + FiscalQuarterNumber - @CurrentFiscalQuarter,
		--Month, week, and day offsets are always same as calendar offsets
		[FiscalMonthOffsetFromToday] = DATEDIFF(MONTH, GETDATE(), [DimDate].[Date]),
		[FiscalWeekOffsetFromToday] = DATEDIFF(WEEK, GETDATE(), [DimDate].[Date]),
		[FiscalDayOffsetFromToday] = DATEDIFF(DAY, GETDATE(), [DimDate].[Date]),
		--Flags
		[IsFutureDate] = CONVERT(BIT, CASE WHEN [DimDate].[Date] >= GETDATE() THEN 1 ELSE 0 END),
		[IsHoliday] = ISNULL(bc.[IsHoliday], 0),
		[HolidayName] = bc.[HolidayName],
		--When its a weekend or holiday then we dont consider it a business day
		[IsBusinessDay] = CONVERT(BIT, CASE WHEN [IsWeekend] = 1 OR ISNULL(bc.[IsBusinessDay], 1) = 0 THEN 0 ELSE 1 END),
		[IsCurrentCalendarYear] = CONVERT(BIT, CASE WHEN GETDATE() BETWEEN [DimDate].[FirstDateOfCalendarYear] AND [DimDate].[LastDateOfCalendarYear] THEN 1 ELSE 0 END),
		[IsCurrentFiscalYear] = CONVERT(BIT, CASE WHEN GETDATE() BETWEEN [DimDate].[FirstDateOfFiscalYear] AND [DimDate].[LastDateOfFiscalYear] THEN 1 ELSE 0 END),
		[IsCurrentCalendarQuarter] = CONVERT(BIT, CASE WHEN GETDATE() BETWEEN [DimDate].[FirstDateOfCalendarQuarter] AND [DimDate].[LastDateOfCalendarQuarter] THEN 1 ELSE 0 END),
		[IsCurrentFiscalQuarter] = CONVERT(BIT, CASE WHEN GETDATE() BETWEEN [DimDate].[FirstDateOfFiscalQuarter] AND [DimDate].[LastDateOfFiscalQuarter] THEN 1 ELSE 0 END),
		[IsCurrentMonth] = CONVERT(BIT, CASE WHEN GETDATE() BETWEEN [DimDate].[FirstDateOfMonth] AND [DimDate].[LastDateOfMonth] THEN 1 ELSE 0 END),
		[IsCurrentWeek] = CONVERT(BIT, CASE WHEN GETDATE() BETWEEN [DimDate].[FirstDateOfWeek] AND [DimDate].[LastDateOfWeek] THEN 1 ELSE 0 END),
		[IsToday] = CONVERT(BIT, CASE WHEN CAST(GETDATE() AS DATE) = [DimDate].[Date] THEN 1 ELSE 0 END)
	FROM [dbo].[DimDate]
	LEFT OUTER JOIN [Stage].[BusinessCalendar] bc ON (DimDate.[Date] = bc.[Date])
	--Dont change the unknown date record
	WHERE DimDate.[IsUnknownDate] = 0;


	--
	--Calculate our business day counts
	--
	UPDATE [dbo].[DimDate]
	SET
		[NumBusinessDaysInCalendarYear] = (SELECT COUNT(*) FROM [dbo].[DimDate] d WHERE d.CalendarYearNumber = DimDate.CalendarYearNumber AND d.IsBusinessDay = 1),
		[NumBusinessDaysInFiscalYear] = (SELECT COUNT(*) FROM [dbo].[DimDate] d WHERE d.FiscalYearNumber = DimDate.FiscalYearNumber AND d.IsBusinessDay = 1),
		[NumBusinessDaysInWeek] = (SELECT COUNT(*) FROM [dbo].[DimDate] d WHERE d.CalendarYearNumber = DimDate.CalendarYearNumber AND d.CalendarWeekNumber = DimDate.CalendarWeekNumber AND d.IsBusinessDay = 1),
		[NumBusinessDaysInCalendarQuarter] = (SELECT COUNT(*) FROM [dbo].[DimDate] d WHERE d.CalendarYearNumber = DimDate.CalendarYearNumber AND d.CalendarQuarterNumber = DimDate.CalendarQuarterNumber AND d.IsBusinessDay = 1),
		[NumBusinessDaysInFiscalQuarter] = (SELECT COUNT(*) FROM [dbo].[DimDate] d WHERE d.FiscalYearNumber = DimDate.FiscalYearNumber AND d.FiscalQuarterNumber = DimDate.FiscalQuarterNumber AND d.IsBusinessDay = 1),
		[NumBusinessDaysInMonth] = (SELECT COUNT(*) FROM [dbo].[DimDate] d WHERE d.CalendarYearNumber = DimDate.CalendarYearNumber AND d.CalendarMonthNumber = DimDate.CalendarMonthNumber AND d.IsBusinessDay = 1)
	--Dont change the unknown date record
	WHERE [IsUnknownDate] = 0;	

END;