@echo off

set ENDPOINT=http://127.0.0.1:4566
set REGION=us-east-1

set AWS_ACCESS_KEY_ID=test
set AWS_SECRET_ACCESS_KEY=test
set AWS_DEFAULT_REGION=%REGION%

echo ========================================
echo Criando recursos de teste no LocalStack
echo Endpoint: %ENDPOINT%
echo ========================================
echo.

echo Criando S3 bucket...
aws --endpoint-url=%ENDPOINT% s3 mb s3://s3-test

echo Criando SQS queue...
aws --endpoint-url=%ENDPOINT% sqs create-queue ^
  --queue-name sqs-test

echo Criando SNS topic...
aws --endpoint-url=%ENDPOINT% sns create-topic ^
  --name sns-test

echo Criando DynamoDB table...
aws --endpoint-url=%ENDPOINT% dynamodb create-table ^
  --table-name dynamodb-test ^
  --attribute-definitions AttributeName=id,AttributeType=S ^
  --key-schema AttributeName=id,KeyType=HASH ^
  --billing-mode PAY_PER_REQUEST

echo Criando Lambda function...
:: Cria um arquivo dummy em python, compila em zip via PowerShell e limpa o arquivo python
echo def handler(event, context): return "Hello" > lambda-test.py
powershell -command "Compress-Archive -Path 'lambda-test.py' -DestinationPath 'lambda-test.zip' -Force"
aws --endpoint-url=%ENDPOINT% lambda create-function ^
  --function-name lambda-test ^
  --runtime python3.11 ^
  --handler lambda-test.handler ^
  --zip-file fileb://lambda-test.zip ^
  --role arn:aws:iam::000000000000:role/lambda-test
del lambda-test.py

echo Criando Kinesis stream...
aws --endpoint-url=%ENDPOINT% kinesis create-stream ^
  --stream-name kinesis-test ^
  --shard-count 1

echo Criando Firehose stream...
aws --endpoint-url=%ENDPOINT% firehose create-delivery-stream ^
  --delivery-stream-name firehose-test ^
  --delivery-stream-type DirectPut

echo Criando EventBridge bus...
aws --endpoint-url=%ENDPOINT% events create-event-bus ^
  --name events-test

echo Criando CloudWatch log group...
aws --endpoint-url=%ENDPOINT% logs create-log-group ^
  --log-group-name logs-test

echo Criando Step Functions state machine...
aws --endpoint-url=%ENDPOINT% stepfunctions create-state-machine ^
  --name stepfunctions-test ^
  --definition "{\"StartAt\":\"Hello\",\"States\":{\"Hello\":{\"Type\":\"Pass\",\"End\":true}}}" ^
  --role-arn arn:aws:iam::000000000000:role/stepfunctions-test

echo Criando secret...
aws --endpoint-url=%ENDPOINT% secretsmanager create-secret ^
  --name secretsmanager-test ^
  --secret-string "{\"test\":\"value\"}"

echo Criando SSM parameter...
aws --endpoint-url=%ENDPOINT% ssm put-parameter ^
  --name ssm-test ^
  --value "test-value" ^
  --type String

echo Criando KMS key...
aws --endpoint-url=%ENDPOINT% kms create-key ^
  --description "kms-test"

echo Criando OpenSearch domain...
aws --endpoint-url=%ENDPOINT% opensearch create-domain ^
  --domain-name opensearch-test

echo Criando Scheduler...
aws --endpoint-url=%ENDPOINT% scheduler create-schedule ^
  --name scheduler-test ^
  --schedule-expression "rate(5 minutes)" ^
  --flexible-time-window Mode=OFF ^
  --target Arn=arn:aws:sqs:us-east-1:000000000000:sqs-test,RoleArn=arn:aws:iam::000000000000:role/scheduler-test

echo Criando CloudWatch alarm...
aws --endpoint-url=%ENDPOINT% cloudwatch put-metric-alarm ^
  --alarm-name cloudwatch-test ^
  --comparison-operator GreaterThanThreshold ^
  --evaluation-periods 1 ^
  --metric-name CPUUtilization ^
  --namespace AWS/EC2 ^
  --period 60 ^
  --threshold 80 ^
  --statistic Average

echo.
echo ========================================
echo Todos os recursos criados com sufixo -test
echo ========================================