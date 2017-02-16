!!!add all aws steps

Repository is mainly to try and tesk different SDKs and framworks.

- slack-bot-common
    - just simple implementation based on python SDK.

## Claudiajs Bots

Bot creation requires few imporant steps:
- Configuration of AWS infrastructure (provisining will be done automatically by Claudiajs)
- Implementation of bot logic
- Deployment

### AWS Infrastructure Configuration
From the security perspective it makes sense to have a separate AWS credentials and IAM account for provisining and configuration of bot. Therefore, we need to check current AWS credential configuration:
```
$ cat ~/.aws/credentials 
```

Typically you will default profile configured:
```
[default]
aws_access_key_id = ***KEY-ID***
aws_secret_access_key = ***ACCESS-KEY***
```

Let start with creation of new IAM User, using floowing command:
```
$ aws iam create-user --user-name bot-account-general

"User": {
        "UserName": "bot-account-general", 
        "Path": "/", 
        "CreateDate": "2017-02-16T14:29:22.082Z", 
        "UserId": "AIDAJYUISVZFGHGHJSUO", 
        "Arn": "arn:aws:iam::465465780645:user/bot-account-general"
}
```

Attached required policies for managing Lambda and API Gateway (AWSLambdaFullAccess, AmazonAPIGatewayAdministrator):
```
$ aws iam attach-user-policy --policy-arn arn:aws:iam::aws:policy/AWSLambdaFullAccess --user-name bot-account-general
$ aws iam attach-user-policy --policy-arn arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator --user-name bot-account-general
$ aws iam attach-user-policy --policy-arn arn:aws:iam::aws:policy/IAMReadOnlyAccess --user-name bot-account-general
```

Create access key:
```
$ aws iam create-access-key --user-name bot-account-general | jq -r '@text "[bot-profile]\naws_access_key_id =  \(.AccessKey.AccessKeyId)\naws_secret_access_key = \(.AccessKey.SecretAccessKey)"' >> ~/.aws/credentials
```

### Bot Implementation

Install Claudia
```
$ npm install claudia -g
```

Init project, add claudia-bot-builder dependency
```
npm init
npm install claudia-bot-builder -S
```

Create bot.js:
```
var botBuilder = require('claudia-bot-builder');

module.exports = botBuilder(function (request) {
  return 'hello';
});
```

### Deploy Bot

First time depoyment via create:
```
claudia create \
    --region us-east-1 \
    --profile claudia-bot \
    --role lambda-execution-role-bot \
    --api-module bot
```

If claudia.json is already created then:
```
claudia update \
    --region us-east-1 \
    --profile claudia-bot \
    --api-module bot
```

### Deploy different bot versions

TODO