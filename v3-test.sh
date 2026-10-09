#!/usr/bin/env bash
# Test V3 - the guardrail stops anyone in the production account from turning off audit logging.
# Run in CloudShell in QuickLend-Production (5250-9140-5783), signed in as BreakGlassAdmin.
export AWS_DEFAULT_REGION=ap-southeast-2
echo "Caller:"
aws sts get-caller-identity --query Arn --output text
echo
echo "Attempting to stop the organisation trail..."
aws cloudtrail stop-logging --name quicklend-org-trail
