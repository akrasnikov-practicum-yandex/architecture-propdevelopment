#!/bin/bash
# 1. Создание пользователей (ServiceAccounts) по оргструктуре PropDevelopment

# Бизнес-аналитик (viewers: Task1/2 — только просмотр внутренних данных)
kubectl create serviceaccount viewer-user

# Инженер по эксплуатации (configurators: Task3 — деплой Smart Home сервисов)
kubectl create serviceaccount editor-user

# DevOps-инженер (secrets-admins: Task1/2 — критический доступ к секретам партнёра)
kubectl create serviceaccount sec-admin-user

echo "Пользователи созданы."
