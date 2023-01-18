#!/bin/bash

echo "Setting up localstack profile"
aws configure set aws_access_key_id access_key --profile=localstack
aws configure set aws_secret_access_key secret_key --profile=localstack
aws configure set region $AWS_REGION --profile=localstack
export AWS_DEFAULT_PROFILE=localstack

echo "Creating upload file event SQS"
aws --endpoint-url=http://localstack:4566 sqs create-queue --queue-name $UPLOAD_EVENT_QUEUE

echo "ARN for upload file event SQS"
UPLOAD_EVENT_QUEUE_ARN=$(aws --endpoint-url=http://localstack:4566 sqs get-queue-attributes\
                  --attribute-name QueueArn --queue-url=http://localhost:4566/000000000000/"$UPLOAD_EVENT_QUEUE"\
                  |  sed 's/"QueueArn"/\n"QueueArn"/g' | grep '"QueueArn"' | awk -F '"QueueArn":' '{print $2}' | tr -d '"' | xargs)

echo "Creating delete file event SQS"
aws --endpoint-url=http://localstack:4566 sqs create-queue --queue-name $DELETE_EVENT_QUEUE

echo "ARN for delete file event SQS"
DELETE_EVENT_QUEUE_ARN=$(aws --endpoint-url=http://localstack:4566 sqs get-queue-attributes\
                  --attribute-name QueueArn --queue-url=http://localhost:4566/000000000000/"$DELETE_EVENT_QUEUE"\
                  |  sed 's/"QueueArn"/\n"QueueArn"/g' | grep '"QueueArn"' | awk -F '"QueueArn":' '{print $2}' | tr -d '"' | xargs)

echo "Create S3 bucket" 
aws --endpoint-url=http://localhost:4566 s3api create-bucket\
    --bucket $BUCKET_NAME --region $AWS_REGION\
    --create-bucket-configuration LocationConstraint=$AWS_REGION

echo "Set S3 bucket notification configurations"
aws --endpoint-url=http://localhost:4566 s3api put-bucket-notification-configuration\
    --bucket $BUCKET_NAME\
    --notification-configuration  '{
                                      "QueueConfigurations": [
                                         {
                                           "QueueArn": "'"$UPLOAD_EVENT_QUEUE_ARN"'",
                                           "Events": ["s3:ObjectCreated:*"]
                                         },
                                         {
                                            "QueueArn": "'"$DELETE_EVENT_QUEUE_ARN"'",
                                            "Events": ["s3:ObjectRemoved:*"]
                                          }
                                       ]
                                     }'


echo "READY TO GO!"
