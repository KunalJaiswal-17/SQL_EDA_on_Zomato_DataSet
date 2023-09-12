Select * From zomatoData;

Select * From Country;


-- Question 1: How are the restaurants listed on Zomato distributed all around the World?
/*
Select cc.Country, Count(zd.RestaurantName) TotalRestaurant
from zomatoData zd
Join Country cc
	On zd.CountryCode = cc.CountryCode
Group By cc.Country;
*/

with TotalRestaurants As(
	Select Count(RestaurantName) TotalCount
	From zomatoData
)

SELECT
    cc.Country, COUNT(zd.RestaurantName) NumRestaurants,
    Format((COUNT(zd.RestaurantName) * 100.0 / (SELECT TotalCount FROM TotalRestaurants)),'0.00') Percentage
FROM zomatoData zd
Join Country cc
	On zd.CountryCode = cc. CountryCode
GROUP BY cc.Country
ORDER BY NumRestaurants DESC;

-- Question 2: What is the Average Cost (for Two) at Restaurant in each city of India?

Select zd.City, Sum(zd.AverageCostforTwo) AverageCost, Count(zd.RestaurantName) TotalRestaurant
from zomatoData zd
Join Country cc
	On zd.CountryCode = cc. CountryCode
Where cc.Country = 'India'
Group By zd.City
Order By AverageCost DESC;


-- Question 3: Top 5 Expensive Cities in India according to the Average Cost(for Two) Per Restaurant.

Select Top 5 zd.City, Count(zd.RestaurantName) TotalRestaurant, Round((Sum(zd.AverageCostforTwo)/Count(zd.RestaurantName)),2) AvgCostPerRestaurant
from zomatoData zd
Join Country cc
	On zd.CountryCode = cc. CountryCode
Where cc.Country = 'India'
Group By zd.City
Order By AvgCostPerRestaurant DESC;


-- Question 4: How do restaurants with high ratings and low ratings differ in terms of the number of votes they receive?

DECLARE @HighRating FLOAT = 4.0;
DECLARE @LowRating FLOAT = 2.0;

SELECT
    CASE
        WHEN AggregateRating >= @HighRating THEN 'High Rating'
        WHEN AggregateRating <= @LowRating THEN 'Low Rating'
        ELSE 'Medium Rating'
    END AS RatingCategory,
    Format(AVG(Votes),'0.00') AS AvgVotes
FROM zomatoData
GROUP BY
    CASE
        WHEN AggregateRating >= @HighRating THEN 'High Rating'
        WHEN AggregateRating <= @LowRating THEN 'Low Rating'
        ELSE 'Medium Rating'
    END;


-- Question 5: Do restaurants with online delivery tend to have higher ratings?

SELECT
    CASE
        WHEN HasOnlinedelivery = 'Yes' THEN 'With Online Delivery'
        ELSE 'Without Online Delivery'
    END AS DeliveryStatus,
    Format(AVG(AggregateRating), '0.00') AverageRating
FROM zomatoData 
GROUP BY
    CASE
        WHEN HasOnlinedelivery = 'Yes' THEN 'With Online Delivery'
        ELSE 'Without Online Delivery'
    END;


-- Question 6: List Out top 5 Restaurant in New Delhi With rating above 4.0 to know what types of cuisines they serve.

Select Top 5 City, Locality, RestaurantName, Cuisines, AggregateRating
From zomatoData
Where AggregateRating > 4.0 And City = 'New Delhi'
Order By AggregateRating DESC;


-- Question 7: Are higher-priced restaurants more likely to have table bookings?

SELECT
    Pricerange,
    COUNT(RestaurantName) TotalRestaurants,
    SUM(CASE WHEN HasTablebooking = 'Yes' THEN 1 ELSE 0 END) Restaurants_With_Booking,
    SUM(CASE WHEN HasTablebooking = 'No' THEN 1 ELSE 0 END) Restaurants_Without_Booking
FROM zomatoData
where Currency = 'Indian Rupees'
GROUP BY Pricerange
ORDER BY Pricerange;

-- Price Range Vs Average Cost(For Two)

Select Pricerange, Format(Avg(AverageCostforTwo),'0.00') AverageCost
From zomatoData
where Currency = 'Indian Rupees'
Group By Pricerange
Order By Pricerange;



-- Question 8: Top 5 Cuisines in India served by the Restaurants

SELECT DISTINCT Trim(c.value) AS UniqueCuisine, AggregateRating
FROM zomatoData
CROSS APPLY STRING_SPLIT(Cuisines, ',') AS c

SELECT UniqueCuisine, Round(AVG(AggregateRating), 1) AS AverageRating, COUNT(RestaurantName) TotalRestaurant
FROM (
    SELECT DISTINCT Trim(value) AS UniqueCuisine, AggregateRating, RestaurantName
    FROM zomatoData 
    CROSS APPLY STRING_SPLIT(Cuisines, ',') AS c
	where CountryCode = 1
) AS CuisineRatings
GROUP BY UniqueCuisine
ORDER BY AverageRating DESC;


SELECT Top 5 UniqueCuisine, Round(AVG(AggregateRating), 1) AS AverageRating, COUNT(RestaurantName) TotalRestaurant
FROM (
    SELECT DISTINCT Trim(value) AS UniqueCuisine, AggregateRating, RestaurantName
    FROM zomatoData 
    CROSS APPLY STRING_SPLIT(Cuisines, ',') AS c
	where CountryCode = 1
) AS CuisineRatings
GROUP BY UniqueCuisine
ORDER BY AverageRating DESC;
