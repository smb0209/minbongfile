@echo off
rem ====================================================================
rem  Calgary Store LG TV Signage - Bulletproof Multi-Stage Version
rem ====================================================================

set "BASE_DIR=C:\adImg"
set "TARGET_DIR=C:\adImg\img"
set "PORT=8080"
set "IP_ADDR=192.168.11.101"
set "JSON_PATH=C:\adImg\menu.json"

echo [1/3] Preparing Directories...
if not exist "%BASE_DIR%" mkdir "%BASE_DIR%"
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"
cd /d "%BASE_DIR%"

echo [2/3] Forcing menu.json Generation via CMD Echo...
rem 이미지 폴더를 스캔하기 전에 우선 기본 구조를 하드코딩으로 확실하게 박아버립니다.
(
echo {
echo   "name": "Calgary Store Signage List",
echo   "type": "list",
echo   "template": { "type": "image", "layout": "0,0,12,12", "color": "msx-black" },
echo   "items": [
echo     {
echo       "title": "Ad Slide 1",
echo       "image": "http://%IP_ADDR%:%PORT%/img/01.jpg",
echo       "properties": { "duration": 10 }
echo     },
echo     {
echo       "title": "Ad Slide 2",
echo       "image": "http://%IP_ADDR%:%PORT%/img/02.jpg",
echo       "properties": { "duration": 10 }
echo     }
echo   ]
echo }
) > "%JSON_PATH%"

echo menu.json has been forced to create in C:\adImg!
echo.

echo [3/3] Launching Safe Web Server via PowerShell...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$port=%PORT%; $netstat=netstat -ano | findstr \":$port \"; if ($netstat) { foreach($line in $netstat) { $procId=($line -split '\s+')[-1]; if ($procId -match '^\d+$') { Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue; } } Start-Sleep -Seconds 1; } $listener=New-Object System.Net.HttpListener; $listener.Prefixes.Add(\"http://*:$port/\"); $listener.Start(); Write-Host '--------------------------------------------------' -ForegroundColor Green; Write-Host \"  Local Server Running on http://%IP_ADDR%:$port  \" -ForegroundColor Green; Write-Host '--------------------------------------------------' -ForegroundColor Green; while ($listener.IsListening) { $context=$listener.GetContext(); $request=$context.Request; $response=$context.Response; $response.Headers.Add('Access-Control-Allow-Origin', '*'); $filePath = 'C:\adImg' + $request.Url.LocalPath.Replace('/', '\'); if (Test-Path $filePath -PathType Leaf) { $bytes=[System.IO.File]::ReadAllBytes($filePath); $response.OutputStream.Write($bytes, 0, $bytes.Length); } else { $response.StatusCode=404; }; $response.Close(); }"

pause
