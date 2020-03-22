CREATE TABLE [dbo].[DimTime] (
    [TimeKey]          INT          NOT NULL,
    [Time]             TIME (0)     NULL,
    [HourNumber]       SMALLINT     NOT NULL,
    [HourNameLong]     VARCHAR (10) NOT NULL,
    [HourNameShort]    VARCHAR (10) NOT NULL,
    [MinuteNumber]     SMALLINT     NOT NULL,
    [MinuteNameLong]   VARCHAR (10) NOT NULL,
    [MinuteNameShort]  VARCHAR (10) NOT NULL,
    [TimeNameStandard] VARCHAR (10) NOT NULL,
    [TimeNameMilitary] VARCHAR (10) NOT NULL,
    [IsUnknownTime]    BIT          NOT NULL,
    CONSTRAINT [PK_DimTime] PRIMARY KEY CLUSTERED ([TimeKey] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_DimTime_Hour_Minute]
    ON [dbo].[DimTime]([HourNumber] ASC, [MinuteNumber] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_DimTime_Time]
    ON [dbo].[DimTime]([Time] ASC);

