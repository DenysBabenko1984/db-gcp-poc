DROP MATERIALIZED VIEW IF EXISTS `hotels_info.hotel_pkg_deals_mv`;

CREATE MATERIALIZED VIEW `hotels_info.hotel_pkg_deals_mv`
OPTIONS(
  max_staleness = INTERVAL 1 HOUR
)
AS
SELECT
  h.hotel_code,  h.hotel_pkg_code,  h.hotel_pkg_name,
  h.start_date,  h.expire_date,     h.pkg_price,
  h.notes
FROM `hotels_info.hotel_pkg_deals_ftbl` AS h;

