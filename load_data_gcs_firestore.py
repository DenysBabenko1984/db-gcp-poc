""" Script reads hotel property info from json file located in a 
google cloud storage bucket. Loads the data into a firestore collection.

Usage:
  python load_data_gcs_firestore.py -p <gcp_project_id> 

  -p, --project: Target GCP project
"""
import argparse
from google.cloud import firestore
from google.cloud import storage
import sys

# class HotelProperty:
#   def __init__(self, hotel_id: str, hotel_name: str, hotel_address: str, hotel_city: str, hotel_state: str, hotel_zip: str, hotel_country: str, hotel_phone: str, hotel_email: str, hotel_website: str, hotel_latitude: float, hotel_longitude: float):
#     self.hotel_id = hotel_id
#     self.hotel_properties = hotel_properties

class GCPhelper:
  # @staticmethod
  # def get_firestore_client(project_id: str) -> firestore.Client:
  #     return firestore.Client(project=project_id)
  
  @staticmethod
  def get_data_from_gcs_ndjson(uri: str) -> str:
    """Read data from a GCS bucket using blob with chunk_size. Iterate
    ndjson file row by row.
    
    Args:
      uri: The GCS URI in format 'gs://bucket-name/path/to/file'
        
    Returns:
      str: The contents of the file row.
    """
    storage_client = storage.Client()
    bucket_name = uri.split('/')[2]
    blob_name = '/'.join(uri.split('/')[3:])
    
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(blob_name)
    
    # Read the file in chunks of 1MB
    chunk_size = 1024  # 1KB chunks
    content = []
    last_chunk_row = ''

    try:
      with blob.open('rb') as f:
        while True:
          try:
            chunk = f.read(chunk_size)  # Returns bytes
            if not chunk:
              break
            # Convert bytes to string and process row by row
            chunk_str = last_chunk_row + chunk.decode('utf-8')
            for row in chunk_str.split('\n'):
              if row.strip():  # Skip empty lines
                yield row.strip()
            # if last row do not finish with a newline
            last_chunk_row = '' if row.endswith('\n') else row
          except UnicodeDecodeError as e:
            print(f"Error decoding chunk: {e}")
            continue
          except Exception as e:
            print(f"Error processing chunk: {e}")
            continue
    except Exception as e:
      raise Exception(f"Error accessing GCS: {e}")


def main(args: argparse.Namespace) -> None:
  """Implement the command line interface described in the module doc string."""
  gcp_project_id = args.gcp_project_id
  # iterate hotel records in new line delimeted json file
  for hotel_json in GCPhelper.get_data_from_gcs_ndjson(f"gs://{gcp_project_id}-data/input/hotels.json"):
    print(hotel_json)
  return


if __name__ == '__main__':
  try:
    # Construct the argument parser
    ap = argparse.ArgumentParser(
        description=__doc__
    )
    # Add the arguments to the parser
    ap.add_argument(
        '-p',
        '--project',
        dest='gcp_project_id',
        required=True,
        help='GCP project id')
    main(ap.parse_args())
  except:
    print('Unexpected error:', sys.exc_info()[1])
    raise
