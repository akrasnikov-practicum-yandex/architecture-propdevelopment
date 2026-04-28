# Ролевая модель Kubernetes

| Роль  | Права роли | Группы пользователей |
| --- | --- | --- |
| `pod-viewer` (Role) | `get`, `list`, `watch` ресурсов `pods`, `services`, `configmaps` | `viewers` (Например: Разработчики, Аналитики) |
| `cluster-editor` (Role) | `get`, `list`, `watch`, `create`, `update`, `patch`, `delete` ресурсов `pods`, `services`, `deployments`, `replicasets` | `operators` (Например: Инженеры по эксплуатации) |
| `secret-reader` (Role) | `get`, `list`, `watch` ресурсов `secrets` | `security-admins` (Например: Специалист по ИБ) |
