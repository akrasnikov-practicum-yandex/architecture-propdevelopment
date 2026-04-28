# Task 4 — Ролевой доступ к кластеру Kubernetes (RBAC)

## Цель

Настроить ролевую модель доступа к кластеру Kubernetes для пользователей PropDevelopment по принципу минимальных привилегий (Least Privilege).

Роли отражают решения из предыдущих заданий:
- **Task 1** — классификация данных: API-ключи партнёра «Умный дом» и пароли БД — категория «Секретные данные», критический риск утечки → доступ к `secrets` только у привилегированной группы.
- **Task 2** — чеклист ИБ: требования минимальных привилегий, ограничения на изменение конфигурации, журналирование операций доступа.
- **Task 3** — новые сервисы (Smart Home Adapter, API Gateway, smart-home DB) развёртываются в кластере → инженеры по эксплуатации должны иметь права на управление deployments и networkpolicies.

## Ролевая модель

| ClusterRole | Ресурсы и действия | ServiceAccount | Группы PropDevelopment |
|---|---|---|---|
| `viewer-role` | `get`, `list`, `watch` → pods, pods/log, services, deployments, configmaps, jobs, cronjobs, daemonsets | `viewer-user` | Бизнес-аналитики, Разработчики, Менеджеры |
| `configurator-role` | полный CRUD → pods, deployments, services, configmaps, networkpolicies, jobs, PVC | `editor-user` | Инженеры по эксплуатации, Senior Developers |
| `secrets-admin-role` | полный доступ → secrets, nodes, namespaces, serviceaccounts; управление roles/rolebindings | `sec-admin-user` | DevOps-инженеры, Специалист по ИБ |

Подробное описание: [roles_table.md](roles_table.md)

## Структура файлов

```
Task4/
├── manifests/
│   ├── create-roles.yaml            # ClusterRole — используется скриптами
│   ├── cluster-role-binding.yaml    # ClusterRoleBinding — используется скриптами
│   ├── roles.yaml                   # Role (namespace-scoped, справочно)
│   └── role-binding.yaml            # RoleBinding (namespace-scoped, справочно)
├── roles_table.md                   # Таблица ролей с обоснованием
├── create-users.sh / .ps1           # Скрипт 1 — создание пользователей
├── create-roles.sh / .ps1           # Скрипт 2 — создание ролей
└── bind-roles.sh  / .ps1            # Скрипт 3 — привязка пользователей к ролям
```

## Предварительные требования

```bash
# Запустить Minikube
minikube start

# Убедиться, что kubectl подключён к кластеру
kubectl get nodes
```

## Порядок выполнения

### Linux / macOS

```bash
cd Task4
bash create-users.sh
bash create-roles.sh
bash bind-roles.sh
```

### Windows (PowerShell)

```powershell
cd Task4

# Если выполнение скриптов запрещено:
# Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

.\create-users.ps1
.\create-roles.ps1
.\bind-roles.ps1
```

## Проверка

```bash
# ServiceAccounts созданы
kubectl get serviceaccounts

# ClusterRoles созданы
kubectl get clusterroles | grep -E "viewer-role|configurator-role|secrets-admin-role"

# ClusterRoleBindings созданы
kubectl get clusterrolebindings | grep -E "viewer|configurator|secrets-admin"

# viewer-user — только просмотр, нет доступа к секретам
kubectl auth can-i get pods \
  --as=system:serviceaccount:default:viewer-user       # yes
kubectl auth can-i get secrets \
  --as=system:serviceaccount:default:viewer-user       # no

# editor-user — может управлять deployments, нет доступа к секретам
kubectl auth can-i create deployments \
  --as=system:serviceaccount:default:editor-user           # yes
kubectl auth can-i get secrets \
  --as=system:serviceaccount:default:editor-user           # no

# sec-admin-user — привилегированный доступ к секретам
kubectl auth can-i get secrets \
  --as=system:serviceaccount:default:sec-admin-user      # yes
kubectl auth can-i create rolebindings \
  --as=system:serviceaccount:default:sec-admin-user      # yes
```
