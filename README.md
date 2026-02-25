# localstack
LocalStack Docker Script


brew install awscli
aws --version
python3 -m pip install awscli-local

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
echo $PATH

aws --endpoint-url=http://127.0.0.1:4566 s3 mb s3://bucket-test
aws --endpoint-url=http://127.0.0.1:4566 s3 ls

