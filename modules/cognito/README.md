### This module helps create a Cognito user pool, client and domain
The custom attribute "customerId" still needs to be set using AWS CLI

```
aws cognito-idp admin-update-user-attributes \
--user-pool-id ap-southeast-1_Lf1AnoaWV \
--username salva \
--user-attributes Name="custom:customerId",Value="475142622"
```