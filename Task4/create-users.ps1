# 1. Создание пользователей (ServiceAccounts) по оргструктуре PropDevelopment

# Бизнес-аналитик (viewers)
kubectl create serviceaccount viewer-user
# Инженер по эксплуатации (configurators)
kubectl create serviceaccount editor-user
# DevOps-инженер (secrets-admins)
kubectl create serviceaccount sec-admin-user

Write-Host "Пользователи созданы."
