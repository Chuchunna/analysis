/* 
Objective: Identify the busiest day, week, and month for incident occurrences 
from the contact centre dataset.
Steps:
1. Parse the 'Opened_on' string into a proper date-time format.
2. Calculate busiest day, busiest week, and busiest month separately.
3. Combine results into a single summary table.
*/

-- Step 1: Parse 'Opened_on' into a proper timestamp for consistent date operations
WITH source AS (
    SELECT 
        STRPTIME(Opened_on, '%d/%m/%Y %H:%M') AS parsed_date -- Convert from DD/MM/YYYY HH:MM to TIMESTAMP
    FROM read_csv_auto('contact_centre_dataset (1).csv')
),

-- Step 2a: Find the busiest single day by counting incidents per date
busiest_day AS (
    SELECT 
        CAST(parsed_date AS DATE) AS day,  -- Remove time portion, keeping only the date
        COUNT(*) AS incident_count         -- Count number of incidents for that day
    FROM source
    GROUP BY day
    ORDER BY incident_count DESC           -- Sort so the day with the highest count comes first
    LIMIT 1                                -- Keep only the busiest day
),

-- Step 2b: Find the busiest week by grouping by ISO year-week format
busiest_week AS (
    SELECT 
        STRFTIME(parsed_date, '%Y-%W') AS year_week, -- Year and week number (e.g., 2022-28)
        COUNT(*) AS incident_count
    FROM source
    GROUP BY year_week
    ORDER BY incident_count DESC
    LIMIT 1
),

-- Step 2c: Find the busiest month by grouping by year-month
busiest_month AS (
    SELECT 
        STRFTIME(parsed_date, '%Y-%m') AS year_month, -- Year and month (e.g., 2022-07)
        COUNT(*) AS incident_count
    FROM source
    GROUP BY year_month
    ORDER BY incident_count DESC
    LIMIT 1
)

-- Step 3: Output all busiest periods in one combined result set
SELECT 
    d.day AS busiest_day,
    d.incident_count AS day_incidents,
    w.year_week AS busiest_week,
    w.incident_count AS week_incidents,
    m.year_month AS busiest_month,
    m.incident_count AS month_incidents
FROM busiest_day d, busiest_week w, busiest_month m;

