CREATE TABLE [dbo].[FactExample1] (
    [FactExample1Key]                BIGINT          IDENTITY (1, 1) NOT NULL,
    [BusinessKey1]                   VARCHAR (50)    NOT NULL,
    [BusinessKey2]                   INT             NOT NULL,
    [SomeDateUsedToReferenceDimDate] DATE            NOT NULL,
    [ExampleType2SCDKey]             INT             DEFAULT ((-1)) NOT NULL,
    [DateKey]                        INT             DEFAULT ((-1)) NOT NULL,
    [SampleNumeric]                  NUMERIC (14, 2) NULL,
    [Origin]                         VARCHAR (10)    NULL,
    [CreatedDate]                    DATETIME        DEFAULT (getdate()) NOT NULL,
    [CreatedBy]                      VARCHAR (100)   NULL,
    [ModifiedDate]                   DATETIME        NULL,
    [ModifiedBy]                     VARCHAR (100)   NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_FactExample1_BusinessKey1_BusinessKey2]
    ON [dbo].[FactExample1]([BusinessKey1] ASC, [BusinessKey2] ASC);

