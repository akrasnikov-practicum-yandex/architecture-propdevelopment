#!/bin/bash
# 3. Привязка пользователей к ролям (ClusterRoleBinding)

kubectl apply -f manifests/cluster-role-binding.yaml

echo "Привязки созданы."
