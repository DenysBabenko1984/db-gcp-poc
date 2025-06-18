-- Required user permission.
--   * BigQuery Data Editor (roles/bigquery.dataEditor)
--   * BigQuery Data Owner (roles/bigquery.dataOwner)
--   * BigQuery Admin (roles/bigquery.admin)
--   * storage.buckets.get
--   * storage.objects.get
-- I executed it under my personal account and don't need them as I have Owner permissions

-- 1. Create schema if not exist. By default schema will be created in location US. So we
-- will not worry about cross region data loading\reading from GS.
CREATE SCHEMA IF NOT EXISTS `hotels_info`;

-- 2. Create External unpartitioned table
CREATE OR REPLACE EXTERNAL TABLE `hotels_info.hotel_pkg_deals_ftbl` 
(
  hotel_code NUMERIC,
  hotel_pkg_code NUMERIC,
  hotel_pkg_name STRING,
  start_date DATE,
  expire_date DATE,
  pkg_price NUMERIC,
  notes STRING
)
WITH CONNECTION `db-jetblue-assesment.us.data_lake_connection`
OPTIONS(
  format = 'CSV',
  uris = ['gs://db-jetblue-assesment-data/input/Hotel Package Deals Sample CSV - Sheet1.csv'],
  skip_leading_rows = 1, -- We have a header in a 1st row
  field_delimiter = ',',  -- No quoted strings in file so cannot make an assumption about quotes to be used. Assume unquoted string data
  date_format = 'MM/DD/RR',  -- Ordinary I prefer to ask data providers to provide data in format YYYY-MM-DD if possible.  RRcasts to 20YY YY casts to 19YY
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,  -- If true, allow rows that are missing trailing optional columns.
  max_staleness = INTERVAL 1 HOUR,
  metadata_cache_mode = AUTOMATIC -- We need it for materialized view. AUTOMATIC for the metadata cache to be refreshed.
);

-- SELECT
--   h.hotel_code,  h.hotel_pkg_code,  h.hotel_pkg_name,
--   h.start_date,  h.expire_date,     h.pkg_price,
--   h.notes
-- FROM `hotels_info.hotel_pkg_deals_ftbl` AS h;
