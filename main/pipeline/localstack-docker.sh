docker run --rm --name greenstand-localstack -d \
    -p 4572:4572 \
    -p 4576:4576 \
    -p 8080:8080 \
    -e SERVICES=s3,sqs \
    -e DEBUG=1 \
    -e DATA_DIR=/tmp/localstack/data \
    -e PORT_WEB_UI=8080 \
    -e AWS_ACCESS_KEY_ID=greenstand \
    -e AWS_SECRET_ACCESS_KEY=greenstand \
    -e AWS_DEFAULT_REGION=us-east-1 \
    -v $HOME/docker/volumes/localstack:/tmp/localstack \
    localstack/localstack
