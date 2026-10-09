# QuickLend — Component 1 (Identity, Access and Governance)

Implementation files for Component 1 of Group 23's QuickLend design (42035 Cloud Security, Assessment 3).

| File | What it is |
|---|---|
| `policies/QuickLend-Guardrails.scp.json` | Service control policy attached to the production account: no IAM users or access keys, no stopping CloudTrail, no disabling GuardDuty |
| `policies/quicklend-loan-scoring-data-access.json` | Execution-role policy for the loan-scoring function: four DynamoDB actions on one table, KMS use only through DynamoDB, logs to its own group |
| `c1-customer-api.yaml` | CloudFormation: HTTP API with a Cognito JWT authoriser and a Lambda that enforces per-customer isolation against the verified `sub` claim |
| `deploy.sh` | Deploys the stack and seeds one application for customer A and one for customer B |
| `v1-test.sh` | Test V1: no token → 401; own record → 200; another customer's record → 403 |
| `v3-test.sh` | Test V3: stopping CloudTrail from the production account is denied by the SCP |

Reuse: the SCP attaches unchanged to any other account or OU (staging, development); the template takes the user pool, app client, role and table as parameters.

## Deploy and test (AWS CloudShell, ap-southeast-2)

```bash
./deploy.sh                      # management account: stack + two seeded loan applications
./v1-test.sh <authorization-code>  # right after a customer signs in through Cognito managed login
./v3-test.sh                     # production account, signed in as BreakGlassAdmin
```

## Results (9 October 2026)

| Test | Result |
|---|---|
| V1 — per-customer isolation | no token → **401 Unauthorized**; customer A's own record → **200**; customer A asking for customer B's record → **403 Forbidden** |
| V2 — no long-lived IAM users | `iam:CreateUser` as BreakGlassAdmin (AdministratorAccess) → **denied by explicit deny in SCP** `p-b2dudtwo` |
| V3 — audit trail protected | `cloudtrail:StopLogging` as BreakGlassAdmin → **AccessDeniedException, explicit deny in SCP** `p-b2dudtwo` |
