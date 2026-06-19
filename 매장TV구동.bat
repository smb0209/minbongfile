@echo off
rem ====================================================================
rem  Calgary Store LG TV Signage - Bulletproof One-Line Version
rem ====================================================================

set "BASE_DIR=C:\adImg"
set "TARGET_DIR=C:\adImg\img"
set "PORT=8080"
set "IP_ADDR=192.168.11.101"

echo [1/2] Verifying and Preparing Absolute Directories...
if not exist "%BASE_DIR%" mkdir "%BASE_DIR%"
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

cd /d "%BASE_DIR%"

echo [2/2] Launching Dynamic Server Infrastructure via PowerShell...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$port=%PORT%; $ip='%IP_ADDR%'; $baseDir='%BASE_DIR%'; $targetDir='%TARGET_DIR%'; $jsonPath=Join-Path $baseDir 'menu.json'; $netstat=netstat -ano | findstr \":$port \"; if ($netstat) { $procId=($netstat[0] -split '\s+')[-1]; if ($procId -match '^\d+$') { Write-Host \"Killing old process ID: $procId\" -ForegroundColor Yellow; Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 1; } }; $extensions=@('.jpg', '.jpeg', '.png', '.webp'); $files=Get-ChildItem -Path $targetDir | Where-Object { $extensions -contains $_.Extension.ToLower() } | Sort-Object Name; $items=@(); foreach ($f in $files) { $item=@{ title=$f.BaseName; image=\"http://$($ip):$port/img/$($f.Name)\"; properties=@{ duration=10 }; }; $items+=$item; }; $jsonObj=@{ name='Calgary Store Signage Sorted List'; type='list'; template=@{ type='image'; layout='0,0,12,12'; color='msx-black' }; items=$items; }; $jsonObj | ConvertTo-Json -Depth 4 | Out-File -FilePath $jsonPath -Encoding utf8; Write-Host \"menu.json updated with $($items.Count) images!\" -ForegroundColor Cyan; $listener=New-Object System.Net.HttpListener; $listener.Prefixes.Add(\"http://*:$port/\"); $listener.Start(); Write-Host '--------------------------------------------------' -ForegroundColor Green; Write-Host \"  Local Server Running on http://$($ip):$port  \" -ForegroundColor Green; Write-Host '--------------------------------------------------' -ForegroundColor Green; Write-Host 'Keep this window OPEN. Press Ctrl+C to stop.'; while ($listener.IsListening) { $context=$listener.GetContext(); $request=$context.Request; $response=$context.Response; $response.Headers.Add('Access-Control-Allow-Origin', '*'); $response.Headers.Add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS'); $filePath=Join-Path $baseDir $request.Url.LocalPath.TrimStart('/'); if (Test-Path $filePath -PathType Leaf) { $bytes=[System.IO.File]::ReadAllBytes($filePath); $response.OutputStream.Write($bytes, 0, $bytes.Length); } else { $response.StatusCode=404; }; $response.Close(); }"

pause
