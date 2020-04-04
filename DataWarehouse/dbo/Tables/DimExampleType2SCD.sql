CREATE TABLE [dbo].[DimExampleType2SCD] (
    [ExampleType2SCDKey]      INT             IDENTITY (1, 1) NOT NULL,
    [StartDate]               DATETIME2 (7)   DEFAULT ('1900-01-01 00:00:00.000') NOT NULL,
    [EndDate]                 DATETIME2 (7)   DEFAULT ('9999-12-31 23:59:59.999') NOT NULL,
    [IsCurrent]               BIT             DEFAULT ((1)) NOT NULL,
    [BusinessKey1]            VARCHAR (50)    NULL,
    [BusinessKey2]            INT             NULL,
    [SampleVarcharAttribute]  VARCHAR (50)    NULL,
    [SampleIntAttribute]      INT             NULL,
    [SampleDateTimeAttribute] DATETIME        NULL,
    [SampleDateAttribute]     DATE            NULL,
    [SampleBitAttribute]      BIT             DEFAULT ((0)) NULL,
    [SampleNumericAttribute]  NUMERIC (18, 6) NULL,
    [Origin]                  VARCHAR (10)    NULL,
    [CreatedDate]             DATETIME        DEFAULT (getdate()) NOT NULL,
    [CreatedBy]               VARCHAR (100)   NULL,
    [ModifiedDate]            DATETIME        NULL,
    [ModifiedBy]              VARCHAR (100)   NULL,
    [RecordHash]              CHAR (66)       NULL,
    CONSTRAINT [DimExampleType2SCD_PK] PRIMARY KEY CLUSTERED ([ExampleType2SCDKey] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DimExampleType2SCD_BusinessKey1_BusinessKey2_Startdate_EndDate]
    ON [dbo].[DimExampleType2SCD]([BusinessKey1] ASC, [BusinessKey2] ASC, [StartDate] ASC, [EndDate] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_DimExampleType2SCD_Startdate_EndDate_BusinessKey1_BusinessKey2]
    ON [dbo].[DimExampleType2SCD]([StartDate] ASC, [EndDate] ASC, [BusinessKey1] ASC, [BusinessKey2] ASC);

