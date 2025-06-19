-- The Data Analytics team needs the hotel package deals for each hotel listed in
--  hotel_info_tbl. Please write a query that will join the information in hotel_info_tbl and
--  hotel_pkg_deals_mv on the fields hotel_code and property_id

-- Expected data distribution: 1 (hotel in hotel_info_tbl) -> MANY (deals inhotel_pkg_deals_mv)
-- Accordingly to previous tasks I assume that hotel_info_tbl has no duplicated data.
-- Data quality maintaned during insert\update into Firestore

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
