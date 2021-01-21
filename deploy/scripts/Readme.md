# Creating custom role
customRole.json - Please ensure that the value for subscriptionId ("/subscriptions/[subscriptionId]")  in the "AssignableScopes" section is the intended target Azure subscription

example: "/subscriptions/1b851150-8708-42bd-b24e-e88984ca963d"

## Run using Powershell
New-AzRoleDefinition -InputFile "customRole.json"

## Run using  CLI
az role definition create --role-definition customRole.json