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
    INSERT INTO [Stage].[BusinessCalendar] (
        [Date],
        [IsHoliday],
        [HolidayName],
        [IsBusinessDay]
    )
    VALUES 
    ('12/24/2018', 1, 'Christmas Eve', 1),
    ('12/25/2018', 1, 'Christmas', 0),
    --
    ('1/1/2019', 1, 'New Year Day', 0),
    ('5/27/2019', 1, 'Memorial Day', 0),
    ('7/4/2019', 1, 'Independence Day', 0),
    ('7/5/2019', 0, 'Day After Independence Day Floating Holiday', 0),
    ('9/2/2019', 1, 'Labor Day', 0),
    ('11/28/2019', 1, 'Thanksgiving Day', 0),
    ('11/29/2019', 0, 'Day After Thanksgiving', 0),
    ('12/24/2019', 1, 'Christmas Eve', 1),
    ('12/25/2019', 1, 'Christmas', 0),
    ('12/26/2019', 0, 'Year End Closure', 0),
    ('12/27/2019', 0, 'Year End Closure', 0),
    ('12/30/2019', 0, 'Year End Closure', 0),
    ('12/31/2019', 0, 'Year End Closure', 0),
    --
    ('1/1/2020', 1, 'New Year Day', 0),
    ('5/25/2020', 1, 'Memorial Day', 0),
    ('7/3/2020', 0, 'Independence Day (Observed)', 0),
    ('7/4/2020', 1, 'Independence Day', 0),
    ('11/26/2020', 1, 'Thanksgiving Day', 0),
    ('11/27/2020', 0, 'Day After Thanksgiving', 0),
    ('12/24/2020', 1, 'Christmas Eve Floating Holiday', 0),
    ('12/25/2020', 1, 'Christmas', 0),
    ('12/28/2020', 0, 'Year End Closure', 0),
    ('12/29/2020', 0, 'Year End Closure', 0),
    ('12/30/2020', 0, 'Year End Closure', 0),
    ('12/31/2020', 0, 'Year End Closure', 0),
    --
    ('1/1/2021', 1, 'New Year Day', 0);

END;    