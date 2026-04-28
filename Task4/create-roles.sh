#!/bin/bash
# 2. Создание ролей (ClusterRole — кластер PropDevelopment многодоменный)

kubectl apply -f manifests/create-roles.yaml

echo "Роли созданы."
