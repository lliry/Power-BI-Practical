Use [website_traffic_analytics] --website_traffic_analytics;
-- =====================================================================================================================================================
-- Website Traffic Analytics - Sources and Device Types
-- =====================================================================================================================================================

-- Query 1- Session Duration & Page Views - DeviceTypes

SELECT 
    dl.[Device_Type],
    SUM(wtd.[Session_Duration_Seconds])/3600  as 'Total Session Duration(Hrs)',
    ROUND(AVG(wtd.[Session_Duration_Seconds])/3600.00,2) as 'Average Session Duration (Hrs)',
    SUM(wtd.[Page_Views_Per_Session]) as 'Total Page Views'
FROM
    [dbo].[Website_Traffic_Data]  wtd --website_traffic_data wtd
        INNER JOIN
    [dbo].[Device_Lookup] dl on dl.[Device_Key] = wtd.[Device_Key]
GROUP BY dl.[Device_Type];

-- ===================================================================

-- Query 2 - Session Duration and Page Views- Traffic Source
SELECT
	sl.[Source_Type],
	SUM(wtd.[Session_Duration_Seconds])/3600 'Total Session Duration(Hrs)',
	AVG(wtd.[Session_Duration_Seconds])/3600 'Average Session Duration(Hrs)',
	SUM(wtd.[Page_Views_Per_Session]) 'Total Page Views'
FROM [dbo].[Website_Traffic_Data] wtd
INNER JOIN [dbo].[Source_Lookup] sl
ON wtd.Source_Key = sl.Source_Key
GROUP BY sl.Source_Type
-- ===================================================================
-- Query 3 - Bounce Rate by Device Type
With cte1 as (SELECT
	dl.[Device_Type],
	COUNT(wtd.[Session_Id])/1.00 as 'totsessions'
FROM [dbo].[Website_Traffic_Data] wtd
INNER JOIN [dbo].[Device_Lookup] dl
ON dl.[Device_Key] = wtd.[Device_Key]
GROUP BY dl.[Device_Type])
SELECT 
	dl.[Device_Type],
	(COUNT(wtd.[Session_Id])/MAX(cte1.[totsessions])) * 100 as "Bounce_	Rate"
FROM [website_traffic_analytics].[dbo].[Website_Traffic_Data] wtd
INNER JOIN [dbo].[Device_Lookup] dl
ON dl.[Device_Key] = wtd.[Device_Key]
INNER JOIN cte1
ON cte1.[Device_Type] = dl.[Device_Type]
WHERE wtd.[Page_Views_Per_Session] <2
GROUP BY dl.[Device_Type]
-- ===================================================================

-- Query 4 Bounce Rate by Device Browser
With cte1 as (SELECT
	dl.[Device_Browser],
	COUNT(wtd.[Session_Id])/1.00 as 'totsessions'
FROM [dbo].[Website_Traffic_Data] wtd
INNER JOIN [dbo].[Device_Lookup] dl
ON dl.[Device_Key] = wtd.[Device_Key]
GROUP BY dl.[Device_Browser])
SELECT 
	dl.[Device_Browser],
	(COUNT(wtd.[Session_Id])/MAX(cte1.[totsessions])) * 100 as "Bounce_	Rate"
FROM [website_traffic_analytics].[dbo].[Website_Traffic_Data] wtd
INNER JOIN [dbo].[Device_Lookup] dl
ON dl.[Device_Key] = wtd.[Device_Key]
INNER JOIN cte1
ON cte1.[Device_Browser] = dl.[Device_Browser]
WHERE wtd.[Page_Views_Per_Session] <2
GROUP BY dl.[Device_Browser]		

-- ===================================================================

-- Query 5 Bounce Rate by Website Traffic Sources

With cte1 as (SELECT
	sl.[Source_Type],
	COUNT(wtd.[Session_Id])/1.00 as 'totsessions'
FROM [dbo].[Website_Traffic_Data] wtd
INNER JOIN [dbo].[Source_Lookup] sl
ON sl.Source_Key = wtd.Source_Key
GROUP BY sl.Source_Type)
SELECT 
	sl.[Source_Type],
	(COUNT(wtd.[Session_Id])/MAX(cte1.[totsessions])) * 100 as "Bounce_	Rate"
FROM [website_traffic_analytics].[dbo].[Website_Traffic_Data] wtd
INNER JOIN [dbo].[Source_Lookup] sl
ON sl.Source_Key = wtd.Source_Key
INNER JOIN cte1
ON cte1.[Source_Type] = sl.[Source_Type]
WHERE wtd.[Page_Views_Per_Session] <2
GROUP BY sl.[Source_Type]
		
-- ===================================================================		
-- Query 6 Bounce Rate by Content Segment
With cte1 as (SELECT
	dl.[Content_Segment],
	COUNT(wtd.[Session_Id])/1.00 as 'totsessions'
FROM [dbo].[Website_Traffic_Data] wtd
INNER JOIN [dbo].[Device_Lookup] dl
ON dl.[Device_Key] = wtd.[Device_Key]
GROUP BY dl.[Content_Segment])
SELECT 
	dl.[Content_Segment],
	(COUNT(wtd.[Session_Id])/MAX(cte1.[totsessions])) * 100 as "Bounce_	Rate"
FROM [website_traffic_analytics].[dbo].[Website_Traffic_Data] wtd
INNER JOIN [dbo].[Device_Lookup] dl
ON dl.[Device_Key] = wtd.[Device_Key]
INNER JOIN cte1
ON cte1.[Content_Segment] = dl.[Content_Segment]
WHERE wtd.[Page_Views_Per_Session] <2
GROUP BY dl.[Content_Segment]

-- =====================================================================================================================================================
-- Website Traffic Analytics - Trend Based
-- =====================================================================================================================================================
-- Query 7 Total Session Durartion - Trend based on Device Type 

Select
Year(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y')) as Year,
quarter(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y')) as Quarter,
dl.Device_Type,
SUM(wtd.Session_Duration) / 3600 as 'TotalSessionDuration_Hrs'
FROM
    website_traffic_analytics.website_traffic_data wtd
    Inner join device_lookup dl on dl.Device_Key = wtd.Device_Key
    group by Year,Quarter ,dl.Device_Type   
    Order by  dl.Device_Type,Year , Quarter;
	
-- ===================================================================

-- Query 8  Total Session Durartion - Trend based on Website Traffic Source  
        
Select 
Year(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y')) as Year,
quarter(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y')) as Quarter,
sl.Source_Type as 'WebsiteTrafficSource',
SUM(wtd.Session_Duration) / 3600 as 'TotalSessionDuration_Hrs'
FROM
    website_traffic_analytics.website_traffic_data wtd
    Inner join source_lookup sl on wtd.Source_Key = sl.Source_Key
    group by Year,Quarter ,sl.Source_Type 
    Order by  sl.Source_Type,Year , Quarter;
	
-- ===================================================================

-- Query 9 Average Session Duration (Hrs) - Overall Trend

Select 
Year(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y')) as Year,
quarter(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y')) as Quarter,
AVG(wtd.Session_Duration) / 3600 as 'TotalSessionDuration_Hrs'
FROM
    website_traffic_analytics.website_traffic_data wtd
   group by Year,Quarter 
    Order by  Year , Quarter;
	

-- ===================================================================


-- Query 10 - Bounce Rate - Monthly Trend
with cte1 as
(Select 
monthname(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y')) as Month_Name,
count(Session_Id) as totcount
FROM
    website_traffic_analytics.website_traffic_data wtd 
    group by Month_Name)
    
Select 
monthname(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y')) as Month_Name1,
count(Session_Id) / MAX(cte1.totcount) * 100 as "Bounce_Rate"
FROM
    website_traffic_analytics.website_traffic_data wtd 
    inner join cte1 on 
		cte1.Month_Name = monthname(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y'))
    WHERE
		wtd.Page_Views_Per_Session < 2
		group by Month_Name1 , Month(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y'))
        Order bY Month(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y'));
		
-- ===================================================================

-- Query 11 ------ Bounce Rate - Daily Trend
with cte1 as
(Select 
dayname(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y')) as WeekDay,
count(Session_Id) as totcount
FROM
    website_traffic_analytics.website_traffic_data wtd 
    group by WeekDay)
    
Select 
dayname(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y')) as WeekDay1,
count(Session_Id) / MAX(cte1.totcount) * 100 as "Bounce_Rate"
FROM
    website_traffic_analytics.website_traffic_data wtd 
    inner join cte1 on 
		cte1.WeekDay = dayname(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y'))
    WHERE
		wtd.Page_Views_Per_Session < 2
		group by WeekDay1 , WeekDay(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y'))
        Order by WeekDay(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y')) ;
		
		
-- =====================================================================================================================================================
-- Website Traffic Analytics - Geographical Analytics
-- =====================================================================================================================================================

-- Query 12 -- -------- Total Page Views - Regionwise
Use website_traffic_analytics;
SELECT 
    gl.location_region AS Region,
    SUM(wtd.page_views_per_session) / (SELECT 
            SUM(wtd.page_views_per_session)
        FROM
            website_traffic_analytics.website_traffic_data wtd) * 100 AS '% of Total_Page_Views'
FROM
    website_traffic_analytics.website_traffic_data wtd
        INNER JOIN
    Geo_lookup gl ON gl.location_key = wtd.location_key
GROUP BY gl.location_region;

-- ===================================================================

-- Query 13 -- -------- Total Session Duration - Regionwise
SELECT 
    gl.location_region AS Region,
    SUM(wtd.Session_Duration) / (SELECT 
            SUM(wtd.Session_Duration)
        FROM
            website_traffic_analytics.website_traffic_data wtd) * 100 AS '% of Total_Session_Duration'
FROM
    website_traffic_analytics.website_traffic_data wtd
        INNER JOIN
    Geo_lookup gl ON gl.location_key = wtd.location_key
GROUP BY gl.location_region;

-- ===================================================================
-- Query 14 -- -------- Bounce Rate - Regionwise
With cte1 as
(SELECT gl.Location_Region ,
            Count(wtd.session_id) as 'totcount'
        FROM
            website_traffic_analytics.website_traffic_data wtd 
            Inner join 
            geo_lookup gl on 
            gl.Location_Key = wtd.Location_Key
            Group by Location_Region)

SELECT 
    gl.location_region AS Region,
    Count(wtd.session_id) / max(cte1.totcount)  * 100 AS 'Bounce Rate'
FROM
    website_traffic_analytics.website_traffic_data wtd
        INNER JOIN
    Geo_lookup gl ON gl.location_key = wtd.location_key
    INNER JOIN cte1 ON cte1.Location_Region = gl.location_region
    Where wtd.Page_Views_Per_Session < 2
GROUP BY gl.location_region;

-- ===================================================================

-- Query 15 Total Session Duration - Top 5 cities

Select * from (
Select *,DENSE_RANK() over(order by TotalSessionDuration desc) as rnk from (SELECT 
    gl.location_city AS City,
    SUM(wtd.Session_Duration) /3600 as 'TotalSessionDuration'
FROM
    website_traffic_analytics.website_traffic_data wtd
        INNER JOIN
    Geo_lookup gl ON gl.location_key = wtd.location_key
GROUP BY gl.location_city
) a ) b 
Where b.rnk <6;

-- ===================================================================

-- Query 16 Total Page Views - Top 5 cities

Select * from (
Select *,DENSE_RANK() over(order by TotalPageViews desc) as rnk from (SELECT 
    gl.location_city AS City,
    SUM(wtd.Page_Views_Per_Session)  'TotalPageViews'
FROM
    website_traffic_analytics.website_traffic_data wtd
        INNER JOIN
    Geo_lookup gl ON gl.location_key = wtd.location_key
GROUP BY gl.location_city
) a ) b 
Where b.rnk <6;

-- ===================================================================

-- Query 17 Total Number of Sessions - Top 5 Cities
Select * from (
Select *,DENSE_RANK() over(order by TotalNumberSessions desc) as rnk from (SELECT 
    gl.location_city AS City,
    Count(wtd.Session_Id)  'TotalNumberSessions'
FROM
    website_traffic_analytics.website_traffic_data wtd
        INNER JOIN
    Geo_lookup gl ON gl.location_key = wtd.location_key
GROUP BY gl.location_city
) a ) b 
Where b.rnk <6;

-- ===================================================================
-- Query 18 Bounce Rate - Top 5 Cities
With cte1 as
(SELECT gl.location_city ,
            Count(wtd.Session_Id) as 'totcount'
        FROM
            website_traffic_analytics.website_traffic_data wtd 
            Inner join 
            geo_lookup gl on 
            gl.Location_Key = wtd.Location_Key
            Group by location_city)

Select * from (
Select *,DENSE_RANK() over(order by BounceRate desc) as rnk from (SELECT 
    gl.location_city AS City,
    Count(wtd.Session_Id)/MAX(cte1.totcount) * 100 as BounceRate
FROM
    website_traffic_analytics.website_traffic_data wtd
        INNER JOIN
    Geo_lookup gl ON gl.location_key = wtd.location_key
    Inner join cte1 on cte1.location_city = gl.location_city
    Where wtd.Page_Views_Per_Session < 2
GROUP BY gl.location_city
) a ) b 
Where b.rnk <6;




-- =====================================================================================================================================================
-- Website Traffic Analytics - Dashboard
-- =====================================================================================================================================================

-- Average Session Duration

SELECT 
    AVG(wtd.Session_Duration)/3600
        FROM
            website_traffic_analytics.website_traffic_data wtd;

-- Total  Page Views

SELECT 
    SUM(wtd.Page_Views_Per_Session)
        FROM
            website_traffic_analytics.website_traffic_data wtd;
            
-- Total Session Duration

SELECT 
    SUM(wtd.Session_Duration)/3600
        FROM
            website_traffic_analytics.website_traffic_data wtd;

-- Bounce Rate 

SELECT 
    COUNT(wtd.session_id) / (SELECT 
            COUNT(wtd.session_id) AS 'totcount'
        FROM
            website_traffic_analytics.website_traffic_data wtd) * 100 AS 'Bounce Rate'
FROM
    website_traffic_analytics.website_traffic_data wtd
WHERE
    wtd.Page_Views_Per_Session < 2
;

-- ===================================================================

-- Total Session Duration Trend
Select 
Year(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y')) as Year,
quarter(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y')) as Quarter,
SUM(wtd.Session_Duration) / 3600 as 'TotalSessionDuration_Hrs'
FROM
    website_traffic_analytics.website_traffic_data wtd
   group by Year,Quarter 
    Order by  Year , Quarter;
    
    
    
    
-- Total Page Views Trend
Select 
Year(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y')) as Year,
quarter(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y')) as Quarter,
SUM(wtd.Page_Views_Per_Session)  as 'Total Page Views'
FROM
    website_traffic_analytics.website_traffic_data wtd
   group by Year,Quarter 
    Order by  Year , Quarter;
	

-- Bounce Rate -  Trend
with cte1 as
(Select 
Year(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y')) as Year,
quarter(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y')) as Quarter,
count(Session_Id) as totcount
FROM
    website_traffic_analytics.website_traffic_data wtd 
    group by Year,Quarter)
    
Select 
Year(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y')) as Year,
quarter(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y')) as Quarter,
count(Session_Id) / MAX(cte1.totcount) * 100 as "Bounce_Rate"
FROM
    website_traffic_analytics.website_traffic_data wtd 
    inner join cte1 on 
		cte1.Year = Year(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y')) and
        cte1.Quarter = quarter(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y')) 
    WHERE
		wtd.Page_Views_Per_Session < 2
		group by Year(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y')),quarter(STR_TO_DATE(wtd.Date_key, '%m/%d/%Y')) 
        Order by  Year , Quarter;