aws --endpoint-url=http://localhost:4572 s3 mb s3://greenstand-bucket
aws --endpoint-url=http://localhost:4576 sqs create-queue --queue-name greenstand-queue

# to get the QueueArn
aws --endpoint-url=http://localhost:4576 sqs get-queue-attributes --queue-url http://localhost:4576/queue/greenstand-queue --attribute-names All

# not sure if we need this, but use it to add read permissions
aws --endpoint-url=http://localhost:4572 s3api put-bucket-acl --bucket greenstand-bucket --acl public-read
