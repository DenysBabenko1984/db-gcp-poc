# We now have the materialized view hotel_pkg_deals_mv. However we must keep in
#  mind materialized views will not always have their data up to date because they only
#  contain the data that the google sheet had at the time of materialized view creation. We
#  can counter this by refreshing (recreating) the materialized view once daily to keep the
#  data fresh. How can we do this?

# Answer > We can use the BigQuery API to schedule a job to refresh the materialized view.
##########################################################################################

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GCP_PROJECT_ID=$(jq -r '.GCP_PROJECT_ID' ${SCRIPT_DIR}/../ENVIRONMENT_CONFIG.json)

# Create a scheduled query to refresh the materialized view daily
# Read query from the SQL file
QUERY=$(cat ${SCRIPT_DIR}/06_hotel_pkg_deals_mv.sql)

# bq query \
# --project_id=${GCP_PROJECT_ID} \
# --display_name="refresh_hotel_pkg_deals_mv" \
# --target_dataset="hotels_info" \
# --schedule="every day 00:00"

bq mk --transfer_config \
  --target_dataset=hotels_info \
  --display_name='refresh_view_hotel_pkg_deals_mv' \
  --params='{"query":"${QUERY}"}' \
  --data_source=scheduled_query \
  --schedule="every day 00:00" \
  --project_id=${GCP_PROJECT_ID}




# gcloud scheduler jobs create bigquery \
#   --schedule="0 0 * * *" \
#   --location=${GCP_REGION} \
#   --description="Refresh hotel_pkg_deals_mv materialized view daily" \
#   --query="DROP MATERIALIZED VIEW IF EXISTS \`hotels_info.hotel_pkg_deals_mv\`; CREATE MATERIALIZED VIEW \`hotels_info.hotel_pkg_deals_mv\` OPTIONS(max_staleness = INTERVAL 1 HOUR) AS SELECT h.hotel_code, h.hotel_pkg_code, h.hotel_pkg_name, h.start_date, h.expire_date, h.pkg_price, h.notes FROM \`hotels_info.hotel_pkg_deals_ftbl\` AS h;" \
#   --dataset-id="hotels_info" \
#   --project-id=${GCP_PROJECT_ID} \
#   "refresh_view_hotel_pkg_deals_mv"