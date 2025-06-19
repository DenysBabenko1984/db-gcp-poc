""" Script reads hotel property info from json file located in a 
google cloud storage bucket. Loads the data into a firestore collection.
NDJSON file should be placed in GS bucket
gs://{gcp_project_id}-data/input/hotels.json

Usage:
  python load_data_gcs_firestore.py -p <gcp_project_id> 

  -p, --project: Target GCP project
  -d, --database: Target Firestore database
  -f, --failed-rows-database: Target Firestore database for failed rows
"""

import argparse
from datetime import datetime
from google.cloud import firestore
from google.cloud import storage
from typing import Optional
import sys
import json
import uuid

class GCPhelper:
  
  @staticmethod
  def upsert_firestore_record(
    database: firestore.Client,
    collection_name: str,
    document_id: str,
    document_upsert_timestamp: float,
    payload: dict
  ) -> None:
    """Insert or update record in Firestore DB. If document already exists
    and its timestamp less than upsert_timestamp update it.

    Args:
      database: Firestore client.
      collection_name: Name of the Firestore collection.
      document_id: ID of the document to insert or update.
      document_upsert_timestamp: Timestamp of the upsert operation.
      payload: Dictionary with the data to insert or update.

    Returns:
      None
    """
    doc_ref = database.collection(collection_name).document(document_id)
    doc = doc_ref.get()
    if not doc.exists:
      # Create new document if not exists yet
      doc_ref.set(document_data=payload)
    else:
      # Get document update timestamp accordingly to payload
      doc_update_timestamp = doc.update_time.timestamp()
      # Update existing document if timestamp is less than upsert_timestamp
      if doc_update_timestamp < document_upsert_timestamp:
        doc_ref.set(document_data=payload)
      else:
        # Skip if document timestamp is greater than upsert_timestamp
        pass

  
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
    chunk_size = 1024 * 1024  # 1MB chunks
    content = []
    last_chunk_row = ''

    try:
      with blob.open('rb') as f:
        while True:
          chunk = f.read(chunk_size)  # Returns bytes
          if not chunk:
            break
          # Convert bytes to string and process row by row
          # add a tail of the previous chunk to the current chunk
          chunk_str = last_chunk_row + chunk.decode('utf-8')
          chunk_row_count = chunk_str.count('\n')
          # iterates all rows in a chunk
          for i, row in enumerate(chunk_str.split('\n')):
            # if last row in chunk not a full string
            if (i+1) > chunk_row_count: 
              last_chunk_row = row
            else:
              last_chunk_row = ''
              yield row
          # yield last chunk row if it exists and does not end with \n
        if last_chunk_row and not last_chunk_row.endswith('\n'):
          yield last_chunk_row
    except UnicodeDecodeError as e:
      raise Exception(f"Error decoding chunk: {e}")
    except Exception as e:
      raise Exception(f"Error processing file: {e}")

################################################################################
# Main function
################################################################################
def main(args: argparse.Namespace) -> None:
  """Implement the command line interface described in the module doc string."""
  gcp_project_id = args.gcp_project_id
  target_db = firestore.Client(database=args.database)
  failed_rows_db = firestore.Client(database=args.failed_rows_database)
  # iterate hotel records in new line delimeted json file
  for hotel_row in GCPhelper.get_data_from_gcs_ndjson(f"gs://{gcp_project_id}-data/input/hotels.json"):
    # skip empty lines
    if not hotel_row.strip():
      continue
    try:
      payload = json.loads(hotel_row)
      print(f'Processing hotel: {payload["property_id"]}')
      document_upsert_timestamp = datetime.fromisoformat(
        payload['dates'].get('updated', payload['dates']['added']).
          replace('Z', '+00:00')
      ).timestamp()
      GCPhelper.upsert_firestore_record(
        database=target_db,
        collection_name='hotels',
        document_id=payload['property_id'],  # hotel property id is a document id
        document_upsert_timestamp=document_upsert_timestamp,
        payload=payload
      )
    except Exception as e:
      print(f'Error occured: {str(e)}')
      # Write errors and exception to failed_records collection
      payload = {
        'error': str(e),
        'processing_timestamp': datetime.now().isoformat(),
        'payload': hotel_row
      }
      GCPhelper.upsert_firestore_record(
          database=failed_rows_db,
          collection_name='hotels',
          document_id=str(uuid.uuid4()), # document id as guid for failed rows
          document_upsert_timestamp=datetime.now().timestamp(),
          payload=payload
        )
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
    ap.add_argument(
        '-d',
        '--database',
        dest='database',
        required=False,
        default='(default)',
        help='Firestore database')
    ap.add_argument(
        '-f',
        '--failed-rows-database',
        dest='failed_rows_database',
        required=False,
        default='failed-records',
        help='Firestore database for failed rows')
    main(ap.parse_args())
  except:
    print('Unexpected error:', sys.exc_info()[1])
    raise
