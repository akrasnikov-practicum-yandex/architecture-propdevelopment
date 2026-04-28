# Task 5 — Управление трафиком внутри кластера Kubernetes (NetworkPolicy)

## Цель

Реализовать сетевую микросегментацию между сервисами в одном namespace по принципу zero-trust: запретить весь трафик по умолчанию и разрешить только явно описанные пары взаимодействий.

Задание моделирует ключевое требование архитектуры PropDevelopment — изоляцию внешнего (клиентского) контура от внутреннего (административного), которая закрывает на сетевом уровне инциденты, зафиксированные в [docs/description.md](../docs/description.md): пересечение данных в личном кабинете клиента (CN-3) и доступ партнёра одной УК к данным другой (CN-8).

## Маппинг учебных меток на PropDevelopment

| Метка пода | Что моделирует в PropDevelopment | Данные из [Task 1](../Task1/README.md) | Чем оправдана изоляция (по [Task 2](../Task2/business_systems_security_checklist.md)) |
|---|---|---|---|
| `front-end` | Витрина продаж + клиентское приложение собственника | PD-1, CN-1, CN-7 | I.10 — ограничение доступа извне |
| `back-end-api` | `client-mart-app`, `tenant-core-app`, публичные API | CN-1, CN-3, CN-7 | III.2 — сегментация, III.11 — фильтрация east-west |
| `admin-front-end` | Внутренний CRM, админка УК и менеджеров | IN-3, IN-5 | I.4 — минимальные привилегии, V.3 — разделение тенантов |
| `admin-back-end-api` | `client-crm-app`, `accountant-service-1`, привилегированные операции | CN-3, CN-4, CN-5 (🔴) | I.9 — замкнутые контуры для CN, II.7 — спец. процедуры для ПДн |

Ключевое следствие: `front-end` (внешний контур) **физически не может достучаться** до `admin-back-end-api` — это и есть сетевой аналог защиты от инцидентов CN-3 и CN-8.

## Структура NetworkPolicy

В файле [non-admin-api-allow.yaml](non-admin-api-allow.yaml) применено 6 политик:

| Политика | Назначение |
|---|---|
| `default-deny-all` | Для всех 4 ролей — запрет Ingress и Egress по умолчанию |
| `allow-dns-egress` | Egress к kube-dns (UDP/TCP 53) — иначе резолвинг имён сервисов ломается |
| `non-admin-api-allow` | Ingress на `back-end-api` только от `front-end` |
| `front-end-egress` | Egress с `front-end` только на `back-end-api` |
| `admin-api-allow` | Ingress на `admin-back-end-api` только от `admin-front-end` |
| `admin-front-end-egress` | Egress с `admin-front-end` только на `admin-back-end-api` |

## Структура файлов

```
Task5/
├── README.md
├── non-admin-api-allow.yaml      # 6 NetworkPolicy
├── create-pods.sh / .ps1         # 4 nginx-пода с метками role=...
└── verify-network.sh / .ps1      # 5 проверочных тестов
```

## Предварительные требования

```bash
# CNI с поддержкой NetworkPolicy (Calico/Cilium/Weave).
# По умолчанию kindnet НЕ поддерживает NetworkPolicy.
minikube start --cni=calico

kubectl get nodes
kubectl get pods -n kube-system | grep -E "calico|cilium|weave"
```

## Порядок выполнения

### Linux / macOS

```bash
cd Task5
bash create-pods.sh
kubectl apply -f non-admin-api-allow.yaml
bash verify-network.sh
```

### Windows (PowerShell)

```powershell
cd Task5

# Если выполнение скриптов запрещено:
# Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

.\create-pods.ps1
kubectl apply -f non-admin-api-allow.yaml
.\verify-network.ps1
```

## Ожидаемый результат тестов

| # | Источник | Назначение | Ожидание |
|---|---|---|---|
| 1 | `front-end-app` | `back-end-api-app` | ✅ HTTP 200, страница nginx |
| 2 | `front-end-app` | `admin-back-end-api-app` | ❌ таймаут — изоляция контуров |
| 3 | `admin-front-end-app` | `admin-back-end-api-app` | ✅ HTTP 200 |
| 4 | `admin-front-end-app` | `back-end-api-app` | ❌ таймаут — изоляция контуров |
| 5 | любой из 4 подов | внешний интернет (`example.com`) | ❌ таймаут — Egress закрыт по умолчанию |

## Дополнительная проверка по подсказке task-5.md

```bash
# Под без метки role не должен попасть ни в один контур.
kubectl run test-$RANDOM --rm -i -t --image=alpine -- sh
# / # wget -qO- --timeout=2 http://back-end-api-app
# wget: download timed out  ← подтверждение
```

## Cleanup

```bash
kubectl delete -f non-admin-api-allow.yaml
kubectl delete pod,svc -l role
```

## Связь с предыдущими заданиями

- **Task 1** ([data_security_mindmap.drawio](../Task1/data_security_mindmap.drawio)) — критические данные CN-3, CN-4, CN-5 определяют необходимость изоляции административного контура.
- **Task 2** ([checklist](../Task2/business_systems_security_checklist.md)) — пункты III.2, III.11, I.4, I.9 закрываются именно микросегментацией.
- **Task 4** ([RBAC](../Task4/README.md)) — RBAC ограничивает «кто что может делать с API Kubernetes», NetworkPolicy ограничивает «кто с кем может общаться по сети». Вместе формируют двухуровневую защиту.
