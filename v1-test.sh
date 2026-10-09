#!/usr/bin/env bash
# Test V1 - per-customer isolation. Run in CloudShell, management account.
# Usage: ./v1-test.sh <authorization code from the address bar after the customer signs in>
# The code is single-use and expires after a few minutes: run this straight after signing in.
set -euo pipefail
export AWS_DEFAULT_REGION=ap-southeast-2
CODE="${1:?Paste the code= value from the address bar}"

POOL=ap-southeast-2_Ek97hECd5
CLIENT=3qhfkvm3rupae742hf1h3db8p1
DOMAIN=https://ap-southeast-2ek97hecd5.auth.ap-southeast-2.amazoncognito.com
REDIRECT=https://d84l1y8p4kdic.cloudfront.net
CUSTOMER_A=f9be14f8-b0e1-7060-d684-fff0eacad999
CUSTOMER_B=7d3c5a10-2b4e-4f61-9a8c-0b1e2f3a4c5d

API=$(aws cloudformation describe-stacks --stack-name quicklend-c1-customer-api \
  --query "Stacks[0].Outputs[?OutputKey=='ApiUrl'].OutputValue" --output text)

# The app client is confidential; its secret is read from AWS here and never printed.
SECRET=$(aws cognito-idp describe-user-pool-client --user-pool-id "$POOL" --client-id "$CLIENT" \
  --query UserPoolClient.ClientSecret --output text)

TOKEN=$(curl -s -u "$CLIENT:$SECRET" \
  -d "grant_type=authorization_code&client_id=$CLIENT&code=$CODE&redirect_uri=$REDIRECT" \
  "$DOMAIN/oauth2/token" | python3 -c 'import sys,json; print(json.load(sys.stdin)["id_token"])')

echo "1) No token, customer A's record:"
curl -s -w "   -> HTTP %{http_code}\n" "$API/applications/$CUSTOMER_A"; echo
echo "2) Customer A's token, customer A's record:"
curl -s -w "   -> HTTP %{http_code}\n" -H "Authorization: Bearer $TOKEN" "$API/applications/$CUSTOMER_A"; echo
echo "3) Customer A's token, customer B's record:"
curl -s -w "   -> HTTP %{http_code}\n" -H "Authorization: Bearer $TOKEN" "$API/applications/$CUSTOMER_B"; echo
