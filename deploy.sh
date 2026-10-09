#!/usr/bin/env bash
# Run once in AWS CloudShell, management account (3080-5440-9786), region ap-southeast-2.
# Deploys the customer API (CloudFormation) and seeds one loan application each for customer A and customer B.
set -euo pipefail
export AWS_DEFAULT_REGION=ap-southeast-2
cd "$(dirname "$0")"

aws cloudformation deploy \
  --stack-name quicklend-c1-customer-api \
  --template-file c1-customer-api.yaml

TABLE=quicklend-loan-applications
CUSTOMER_A=f9be14f8-b0e1-7060-d684-fff0eacad999          # the test customer created on 9 Oct
CUSTOMER_B=7d3c5a10-2b4e-4f61-9a8c-0b1e2f3a4c5d          # a second customer's record

aws dynamodb put-item --table-name "$TABLE" --item \
  "{\"customerId\":{\"S\":\"$CUSTOMER_A\"},\"applicationId\":{\"S\":\"APP-1001\"},\"amount\":{\"N\":\"15000\"},\"status\":{\"S\":\"SUBMITTED\"}}"
aws dynamodb put-item --table-name "$TABLE" --item \
  "{\"customerId\":{\"S\":\"$CUSTOMER_B\"},\"applicationId\":{\"S\":\"APP-2001\"},\"amount\":{\"N\":\"42000\"},\"status\":{\"S\":\"APPROVED\"}}"

echo
echo "Deployed. API URL:"
aws cloudformation describe-stacks --stack-name quicklend-c1-customer-api \
  --query "Stacks[0].Outputs[?OutputKey=='ApiUrl'].OutputValue" --output text
