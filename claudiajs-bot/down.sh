#!/bin/bash

set -eu

iamUserName="bot-account-general"
iamExecutionRole="bot-account-general-role"
awsProfile="bot-profile"
region="us-east-1"

attachedRolePolicies="$(aws iam list-attached-role-policies --role-name $iamExecutionRole | jq -r ".AttachedPolicies[].PolicyArn")"

while read -r attachedRolePolicy; do
    printf "\nDelete attached role policy $attachedRolePolicy...\n"
    aws iam detach-role-policy --role-name $iamExecutionRole --policy-arn $attachedRolePolicy
done <<< "$attachedRolePolicies"

printf "\nDelete role $iamExecutionRole...\n"
aws iam delete-role --role-name $iamExecutionRole

claudia destroy \
    --region $region \
    --profile $awsProfile \
    --role $iamExecutionRole \
    --api-module bot
