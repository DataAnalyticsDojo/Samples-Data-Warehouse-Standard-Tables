CREATE TABLE [Stage].[BusinessCalendar] (
    [Date]              DATE         NOT NULL,
    [IsHoliday]         BIT          DEFAULT ((0)) NOT NULL,
    [HolidayName]       VARCHAR (50) NULL,
    [IsBusinessDay]     BIT          DEFAULT ((1)) NOT NULL,
    [NumWorkHoursInDay] NUMERIC(5,2) DEFAULT NULL,
    CONSTRAINT [PK_BusinessCalendar] PRIMARY KEY CLUSTERED ([Date] ASC)
);

