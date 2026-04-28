# Проверка NetworkPolicy: 5 сценариев, ожидания см. в README.md

Write-Host "`n--- Тест 1: front-end -> back-end-api (ДОЛЖЕН РАБОТАТЬ) ---"
kubectl exec front-end-app -- wget -qO- --timeout=3 http://back-end-api-app

Write-Host "`n--- Тест 2: front-end -> admin-back-end-api (ДОЛЖЕН УПАСТЬ ПО ТАЙМАУТУ) ---"
kubectl exec front-end-app -- wget -qO- --timeout=3 http://admin-back-end-api-app
if ($LASTEXITCODE -ne 0) { Write-Host "Успех: доступ запрещён" }

Write-Host "`n--- Тест 3: admin-front-end -> admin-back-end-api (ДОЛЖЕН РАБОТАТЬ) ---"
kubectl exec admin-front-end-app -- wget -qO- --timeout=3 http://admin-back-end-api-app

Write-Host "`n--- Тест 4: admin-front-end -> back-end-api (ДОЛЖЕН УПАСТЬ ПО ТАЙМАУТУ) ---"
kubectl exec admin-front-end-app -- wget -qO- --timeout=3 http://back-end-api-app
if ($LASTEXITCODE -ne 0) { Write-Host "Успех: доступ запрещён" }

Write-Host "`n--- Тест 5: front-end -> внешний интернет (ДОЛЖЕН УПАСТЬ ПО ТАЙМАУТУ) ---"
kubectl exec front-end-app -- wget -qO- --timeout=3 http://example.com
if ($LASTEXITCODE -ne 0) { Write-Host "Успех: внешний Egress закрыт по умолчанию" }
