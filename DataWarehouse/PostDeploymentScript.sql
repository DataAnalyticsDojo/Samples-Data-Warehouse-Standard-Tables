/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

--
--Seed the Business Calendar if it is empty
--
DECLARE @recordCount INT;

SELECT @recordCount = COUNT(*) 
FROM [Stage].[BusinessCalendar];


IF (@recordCount = 0)
BEGIN
    INSERT INTO [Stage].[BusinessCalendar] 
    VALUES 
    ('12/24/2018', 1, 'Christmas Eve', 1),
    ('12/25/2018', 1, 'Christmas', 0);
END;    