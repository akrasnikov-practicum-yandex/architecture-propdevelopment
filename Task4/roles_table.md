# Ролевая модель доступа к кластеру Kubernetes

Роли отражают решения, выработанные в заданиях 1–3:
- **Task 1** — классификация данных: API-ключи партнёра «Умный дом» и пароли БД — категория «Секретные данные», критический риск утечки. Secrets в Kubernetes должны быть доступны только привилегированной группе.
- **Task 2** — чеклист ИБ: требования минимальных привилегий (I.4), ограничения доступа из внешних источников (I.10), журналирование операций (I.6).
- **Task 3** — новые сервисы (Smart Home Adapter, API Gateway, smart-home DB) добавлены в кластер. Инженеры по эксплуатации должны иметь права на их развёртывание и настройку сетевых политик.

| Роль (ClusterRole) | Права роли | K8s ServiceAccount | Группа пользователей PropDevelopment |
| --- | --- | --- | --- |
| `viewer-role` | Чтение (`get`, `list`, `watch`): pods, pods/log, services, deployments, statefulsets, daemonsets, configmaps, jobs, cronjobs. Нет доступа к секретам. | `viewer-user` | Бизнес-аналитики, Разработчики, Менеджеры операционной команды |
| `configurator-role` | Полный CRUD: pods, deployments, services, configmaps, networkpolicies, jobs, cronjobs, daemonsets, PVC. Нет доступа к секретам. | `editor-user` | Инженеры по эксплуатации, Senior Developers |
| `secrets-admin-role` | Полный доступ к secrets, nodes, namespaces, persistentvolumes, serviceaccounts. Управление ролями и привязками (roles, rolebindings, clusterroles, clusterrolebindings). | `sec-admin-user` | DevOps-инженеры, Специалист по ИБ |
