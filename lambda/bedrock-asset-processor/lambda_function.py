import json
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Lambda function to process S3 events when files are uploaded to the assets bucket.
    Logs the filename of uploaded assets for InnovateMart marketing team tracking.
    """
    
    try:
        # Parse the S3 event
        for record in event['Records']:
            # Get the bucket and object key from the event
            bucket_name = record['s3']['bucket']['name']
            object_key = record['s3']['object']['key']
            event_name = record['eventName']
            
            # Log the image received message as required
            logger.info(f"Image received: {object_key}")
            
            # Additional logging for debugging and monitoring
            logger.info(f"Event: {event_name} | Bucket: {bucket_name} | Object: {object_key}")
            
            # Here you could add additional processing logic such as:
            # - Image validation
            # - Thumbnail generation
            # - Metadata extraction
            # - Database updates
            # - Notifications to other services
            
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': f'Successfully processed {len(event["Records"])} file(s)',
                'processed_files': [record['s3']['object']['key'] for record in event['Records']]
            })
        }
        
    except Exception as e:
        logger.error(f"Error processing S3 event: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Error processing file upload',
                'error': str(e)
            })
        }