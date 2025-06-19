-- The Data Analytics team needs the hotel package deals for each hotel listed in
--  hotel_info_tbl. Please write a query that will join the information in hotel_info_tbl and
--  hotel_pkg_deals_mv on the fields hotel_code and property_id

-- On a base of assumption that there is a firestore export job that exports
-- hotel information to the BigQuery table hotel_info_tbl.
-- I assume that we use the "Firebase Export Collections to BigQuery" extension.
-- This extension provides real-time, incremental export of your Firestore collection to BigQuery.
-- Also it generates a view with latest states.

-- View structure something like this. (It can vary depending on the extension version)
-- * document_name: The full path of the Firestore document.
-- * document_id: The ID of the Firestore document.
-- * timestamp: The timestamp of the latest change.
-- * event_id: The unique event identifier for the change.
-- * data: A record containing all fields of the Firestore document (each field in your Firestore document becomes a column in the view).

-- Also from a task it is clear that we have table hotel_info_tbl.
-- From this I assume that table contains curated data.

-- Expected data distribution: 1 (hotel in hotel_info_tbl) -> MANY (deals inhotel_pkg_deals_mv)
-- Accordingly to previous tasks (#01, #02) I assume that hotel_info_tbl has no duplicated data.

SELECT DISTINCT
  deals.hotel_code,
  deals.hotel_pkg_code,
  deals.hotel_pkg_name,
  deals.start_date,
  deals.expire_date,
  deals.pkg_price,
  deals.notes
FROM `hotels_info.hotel_pkg_deals_mv` AS deals
INNER JOIN `hotels_info.hotel_info_tbl` AS hi
  ON deals.hotel_code = hi.hotel_code
  AND deals.property_id = hi.property_id;

-- In case if we work with raw data from a view created
-- by Firebase extension "Firebase Export Collections to BigQuery"
-- we will need to extract hotel_code and property id stored in data field of the view.
