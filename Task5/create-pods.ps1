# nginx:alpine содержит wget (busybox) — нужен для verify-network скриптов
kubectl run front-end-app          --image=nginx:alpine --labels role=front-end          --expose --port 80
kubectl run back-end-api-app       --image=nginx:alpine --labels role=back-end-api       --expose --port 80
kubectl run admin-front-end-app    --image=nginx:alpine --labels role=admin-front-end    --expose --port 80
kubectl run admin-back-end-api-app --image=nginx:alpine --labels role=admin-back-end-api --expose --port 80

Write-Host "Ожидаем запуск подов..."
Start-Sleep -Seconds 10
kubectl get pods,svc
