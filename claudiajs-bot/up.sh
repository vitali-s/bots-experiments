#!/bin/bash

set -eu

iamUserName="bot-account-general"
iamExecutionRole="bot-account-general-role"
awsProfile="bot-profile"
region="us-east-1"


# Update AWS CLI
printf "\nUpdate AWS CLI...\n"
pip install --upgrade --user awscli

# Check currect credentials
printf "\nShow current credentials...\n"
cat ~/.aws/credentials 

# Check account
currentName="$(aws iam get-user --user-name bot-account-general | jq -r ".User.UserName")"

if [ $currentName == $iamUserName ]
then
    printf "\nDelete existing $iamUserName user...\n"

    attachedUserPolicies="$(aws iam list-attached-user-policies --user-name $iamUserName | jq -r ".AttachedPolicies[].PolicyArn")" 

    while read -r attachedUserPolicy; do
        printf "Delete attached user policy $attachedUserPolicy...\n"
        aws iam detach-user-policy --user-name $iamUserName --policy-arn $attachedUserPolicy
    done <<< "$attachedUserPolicies"

    accessKeys="$(aws iam list-access-keys --user-name $iamUserName | jq -r ".AccessKeyMetadata[].AccessKeyId")"

    while read -r accessKey; do
        printf "Delete access key $accessKey...\n"
        aws iam delete-access-key --access-key $accessKey --user-name $iamUserName
    done <<< "$accessKeys"

    aws iam delete-user --user-name $iamUserName
fi

printf "\nCreate user $iamUserName...\n"
aws iam create-user --user-name $iamUserName

# Assign policies
printf "\nAttach policies...\n"
aws iam attach-user-policy --policy-arn arn:aws:iam::aws:policy/AWSLambdaFullAccess --user-name $iamUserName
aws iam attach-user-policy --policy-arn arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator --user-name $iamUserName
aws iam attach-user-policy --policy-arn arn:aws:iam::aws:policy/IAMReadOnlyAccess --user-name $iamUserName

# Create access key
printf "\nCrete access key...\n"
aws iam create-access-key --user-name bot-account-general | jq -r '@text "[bot-profile]\naws_access_key_id =  \(.AccessKey.AccessKeyId)\naws_secret_access_key = \(.AccessKey.SecretAccessKey)"' >> ~/.aws/credentials 

# Check currect credentials
printf "\n\nShow current credentials...\n"
cat ~/.aws/credentials

# Create IAM role
aws iam create-role --role-name $iamExecutionRole --assume-role-policy-document file://roletrustpolicy.json
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AWSLambdaFullAccess --role-name $iamExecutionRole
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator --role-name $iamExecutionRole

if [ ! -f claudia.json ]; then
    printf "\nDeploy bot...\n"
    claudia create \
        --region $region \
        --profile $awsProfile \
        --role $iamExecutionRole \
        --api-module bot
else
    claudia update \
        --region $region \
        --profile $awsProfile \
        --role $iamExecutionRole \
        --api-module bot
fi

