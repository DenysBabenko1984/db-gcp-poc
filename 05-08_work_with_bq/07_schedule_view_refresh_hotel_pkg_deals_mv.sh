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
# replace \n with space
QUERY=$(echo "${QUERY}" | tr '\n' ' ')
# Create JSON params using jq for proper escaping
PARAMS=$(jq -n --arg query "$QUERY" '{"query": $query}')

bq mk --transfer_config \
  --location=us \
  --display_name='refresh_view_hotel_pkg_deals_mv' \
  --params="${PARAMS}" \
  --data_source=scheduled_query \
  --schedule="every day 00:00" \
  --project_id=${GCP_PROJECT_ID}
