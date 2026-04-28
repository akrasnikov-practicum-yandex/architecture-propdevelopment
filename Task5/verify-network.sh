#!/bin/bash

echo "--- Тест 1: front-end -> back-end-api-app (ДОЛЖЕН РАБОТАТЬ) ---"
kubectl exec front-end-app -- wget -qO- --timeout=3 http://back-end-api-app

echo -e "\n--- Тест 2: front-end -> admin-back-end-api-app (ДОЛЖЕН УПАСТЬ ПО ТАЙМАУТУ) ---"
kubectl exec front-end-app -- wget -qO- --timeout=3 http://admin-back-end-api-app || echo "Успех: доступ запрещен!"

echo -e "\n--- Тест 3: admin-front-end -> admin-back-end-api-app (ДОЛЖЕН РАБОТАТЬ) ---"
kubectl exec admin-front-end-app -- wget -qO- --timeout=3 http://admin-back-end-api-app

echo -e "\n--- Тест 4: admin-front-end -> back-end-api-app (ДОЛЖЕН УПАСТЬ ПО ТАЙМАУТУ) ---"
kubectl exec admin-front-end-app -- wget -qO- --timeout=3 http://back-end-api-app || echo "Успех: доступ запрещен!"

echo -e "\n--- Тест 5: front-end -> внешний интернет (ДОЛЖЕН УПАСТЬ ПО ТАЙМАУТУ) ---"
kubectl exec front-end-app -- wget -qO- --timeout=3 http://example.com || echo "Успех: внешний Egress закрыт по умолчанию!"

# Cleanup:
#   kubectl delete -f non-admin-api-allow.yaml
#   kubectl delete pod,svc -l role
