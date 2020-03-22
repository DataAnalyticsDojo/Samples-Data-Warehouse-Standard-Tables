﻿CREATE TABLE [dbo].[DimDate] (
    [DateKey]                          INT          NOT NULL,
    [Date]                             DATE         NOT NULL,
    [CalendarYearNumber]               SMALLINT     NOT NULL,
    [CalendarWeekNumber]               SMALLINT     NOT NULL,
    [CalendarISOWeekNumber]            SMALLINT     NOT NULL,
    [CalendarQuarterNumber]            SMALLINT     NOT NULL,
    [CalendarMonthNumber]              SMALLINT     NOT NULL,
    [CalendarDayOfYear]                SMALLINT     NOT NULL,
    [FiscalYearNumber]                 SMALLINT     NOT NULL,
    [FiscalWeekNumber]                 SMALLINT     NOT NULL,
    [FiscalQuarterNumber]              SMALLINT     NOT NULL,
    [FiscalMonthNumber]                SMALLINT     NOT NULL,
    [FiscalDayOfYear]                  SMALLINT     NOT NULL,
    [CalendarYearOffsetFromToday]      INT          NOT NULL,
    [CalendarQuarterOffsetFromToday]   INT          NOT NULL,
    [CalendarMonthOffsetFromToday]     INT          NOT NULL,
    [CalendarWeekOffsetFromToday]      INT          NOT NULL,
    [CalendarDayOffsetFromToday]       INT          NOT NULL,
    [FiscalYearOffsetFromToday]        INT          NOT NULL,
    [FiscalQuarterOffsetFromToday]     INT          NOT NULL,
    [FiscalMonthOffsetFromToday]       INT          NOT NULL,
    [FiscalWeekOffsetFromToday]        INT          NOT NULL,
    [FiscalDayOffsetFromToday]         INT          NOT NULL,
    [FirstDateOfCalendarYear]          DATE         NOT NULL,
    [LastDateOfCalendarYear]           DATE         NOT NULL,
    [NumDaysInCalendarYear]            SMALLINT     NOT NULL,
    [NumBusinessDaysInCalendarYear]    SMALLINT     NOT NULL,
    [CalendarYearNameLong]             VARCHAR (10) NOT NULL,
    [CalendarYearNameShort]            VARCHAR (10) NOT NULL,
    [FirstDateOfFiscalYear]            DATE         NOT NULL,
    [LastDateOfFiscalYear]             DATE         NOT NULL,
    [NumDaysInFiscalYear]              SMALLINT     NOT NULL,
    [NumBusinessDaysInFiscalYear]      SMALLINT     NOT NULL,
    [FiscalYearNameLong]               VARCHAR (10) NOT NULL,
    [FiscalYearNameShort]              VARCHAR (10) NOT NULL,
    [FirstDateOfWeek]                  DATE         NOT NULL,
    [LastDateOfWeek]                   DATE         NOT NULL,
    [NumDaysInWeek]                    SMALLINT     NOT NULL,
    [NumBusinessDaysInWeek]            SMALLINT     NOT NULL,
    [WeekNameLong]                     VARCHAR (30) NOT NULL,
    [WeekNameShort]                    VARCHAR (30) NOT NULL,
    [FirstDateOfCalendarQuarter]       DATE         NOT NULL,
    [LastDateOfCalendarQuarter]        DATE         NOT NULL,
    [NumDaysInCalendarQuarter]         SMALLINT     NOT NULL,
    [NumBusinessDaysInCalendarQuarter] SMALLINT     NOT NULL,
    [CalendarQuarterNameLong]          VARCHAR (10) NOT NULL,
    [CalendarQuarterNameShort]         VARCHAR (10) NOT NULL,
    [CalendarQuarterAndYearNameLong]   VARCHAR (15) NOT NULL,
    [CalendarQuarterAndYearNameShort]  VARCHAR (10) NOT NULL,
    [FirstDateOfFiscalQuarter]         DATE         NOT NULL,
    [LastDateOfFiscalQuarter]          DATE         NOT NULL,
    [NumDaysInFiscalQuarter]           SMALLINT     NOT NULL,
    [NumBusinessDaysInFiscalQuarter]   SMALLINT     NOT NULL,
    [FiscalQuarterNameLong]            VARCHAR (10) NOT NULL,
    [FiscalQuarterNameShort]           VARCHAR (10) NOT NULL,
    [FiscalQuarterAndYearNameLong]     VARCHAR (15) NOT NULL,
    [FiscalQuarterAndYearNameShort]    VARCHAR (10) NOT NULL,
    [FirstDateOfMonth]                 DATE         NOT NULL,
    [LastDateOfMonth]                  DATE         NOT NULL,
    [NumDaysInMonth]                   SMALLINT     NOT NULL,
    [NumBusinessDaysInMonth]           SMALLINT     NOT NULL,
    [MonthNameLong]                    VARCHAR (10) NOT NULL,
    [MonthNameShort]                   VARCHAR (10) NOT NULL,
    [DayOfWeek]                        SMALLINT     NOT NULL,
    [DayOfMonth]                       SMALLINT     NOT NULL,
    [DayNameLong]                      VARCHAR (9)  NOT NULL,
    [DayNameShort]                     VARCHAR (3)  NOT NULL,
    [DayFullNameLong]                  VARCHAR (30) NOT NULL,
    [DayFullNameShort]                 VARCHAR (30) NOT NULL,
    [IsFutureDate]                     BIT          NOT NULL,
    [IsUnknownDate]                    BIT          NOT NULL,
    [IsWeekend]                        BIT          NOT NULL,
    [IsHoliday]                        BIT          NOT NULL,
    [HolidayName]                      VARCHAR (50) NULL,
    [IsBusinessDay]                    BIT          NOT NULL,
    [IsFirstDayOfCalendarYear]         BIT          NOT NULL,
    [IsLastDayOfCalendarYear]          BIT          NOT NULL,
    [IsFirstDayOfFiscalYear]           BIT          NOT NULL,
    [IsLastDayOfFiscalYear]            BIT          NOT NULL,
    [IsCurrentCalendarYear]            BIT          NOT NULL,
    [IsCurrentFiscalYear]              BIT          NOT NULL,
    [IsCurrentCalendarQuarter]         BIT          NOT NULL,
    [IsCurrentFiscalQuarter]           BIT          NOT NULL,
    [IsCurrentMonth]                   BIT          NOT NULL,
    [IsCurrentWeek]                    BIT          NOT NULL,
    [IsToday]                          BIT          NOT NULL,
    CONSTRAINT [PK_DimDate] PRIMARY KEY CLUSTERED ([DateKey] ASC)
);




GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_DimDate_Date]
    ON [dbo].[DimDate]([Date] ASC);

