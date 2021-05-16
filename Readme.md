### Register User

```
aws cognito-idp sign-up \
  --client-id ${CLIENT_ID} \
  --username ${USER_NAME} \
  --password ${PASSWORD} \ 
  --user-attributes Name=name,Value=${NAME} Name=email,Value=${EMAIL}
```

```
aws cognito-idp admin-confirm-sign-up \
  --user-pool-id ${POOL_ID} \
  --username ${USER_NAME}
```


### Get Token

```
aws cognito-idp initiate-auth \
 --client-id ${CLIENT_ID} \
 --auth-flow USER_PASSWORD_AUTH \
 --auth-parameters USERNAME=${USER_NAME},PASSWORD=${PASSWORD} \
 --query 'AuthenticationResult.IdToken' \
 --output text
```
