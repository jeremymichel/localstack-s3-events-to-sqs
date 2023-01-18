# Localstack S3 with SQS Queued events

## Purpose
To emulate an upload or deletion of an S3 file with events to SQS.

## What does it do

A S3 bucket is created (defaults to `dev` name), with 2 SQS queues, one is for the when a file is uploaded to S3, the other one, when the file is deleted from the S3 buckets.

The init script sets up the bucket as well as the 2 SQS queues.

## Configuration

You may change the variables inside `docker-compose.yaml`, be mindful when changing the region that you have it setup correctly in your AWS config

## Usage

Run the docker-compose and everything should be setup for you, you may then use the api.

```shell
docker-compose up -d
```

### API Usage

Here are some commands to get you started

```shell
#Command to upload file to a bucket
awslocal s3api put-object --bucket dev --key <key> --body <file-name>

#Command to receive upload event message
awslocal sqs receive-message --queue-url=http://localhost:4566/000000000000/post-upload

#Command to delete file from a bucket
awslocal s3api delete-object --bucket dev --key <key>

#Command to receive delete event message
awslocal sqs receive-message --queue-url=http://localhost:4566/000000000000/post-delete
```

In case you do not have awslocal setup, here is an alias you may use in your `.bashrc` or `.zshrc` or similar

```
alias awslocal="AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=eu-west-1 aws --endpoint-url=http://${LOCALSTACK_HOST:-localhost}:4566"
```
