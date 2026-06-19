@echo off
rem ====================================================================
rem  Calgary Store LG TV Signage - Desktop Absolute Path Fixed Version
rem ====================================================================

rem 모든 작업 디렉토리를 C:\adImg 기준으로 강제 고정합니다.
set "BASE_DIR=C:\adImg"
set "TARGET_DIR=C:\adImg\img"
set "PORT=8080"
set "IP_ADDR=192.168.11.210"
set "JSON_PATH=C:\adImg\menu.json"
set "PS_SCRIPT=C:\adImg\server_core.ps1"

echo [1/3] Verifying and Preparing Absolute Directories...
if not exist "%BASE_DIR%" mkdir "%BASE_DIR%"
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

rem 실행 위치가 바탕화면이더라도 작업 디렉토리를 C:\adImg로 강제 변경
cd /d "%BASE_DIR%"

echo [2/3] Generating Dynamic PowerShell Core Script...
(
echo # 1. Kill existing process on port %PORT%
echo $netstat = netstat -ano ^| findstr ":%PORT% "
echo if ^($netstat^) {
echo     $procId = ^($netstat[0] -split '\s+'^)[-1]
echo     if ^($procId -match '^\d+$'^) {
echo         Write-Host "Killing old process ID: $procId" -ForegroundColor Yellow
echo         Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
echo         Start-Sleep -Seconds 1
echo     }
echo }
echo.
echo # 2. Scan images in absolute img folder and SORT BY NAME
echo $extensions = @^(".jpg", ".jpeg", ".png", ".webp"^)
echo $files = Get-ChildItem -Path "C:\adImg\img" ^| Where-Object { $extensions -contains $_.Extension.ToLower^() } ^| Sort-Object Name
echo.
echo $items = @^()
echo foreach ^($f in $files^) {
echo     $item = @{
echo         title = $f.BaseName
echo         image = "http://%IP_ADDR%:%PORT%/img/$^($f.Name^)"
echo         properties = @{ duration = 10 }
echo     }
echo     $items += $item
echo }
echo.
echo $jsonObj = @{
echo     name = "Calgary Store Signage Sorted List"
echo     type = "list"
echo     template = @{ type = "image"; layout = "0,0,12,12"; color = "msx-black" }
echo     items = $items
echo }
echo.
echo $jsonObj ^| ConvertTo-Json -Depth 4 ^| Out-File -FilePath "C:\adImg\menu.json" -Encoding utf8
echo Write-Host "menu.json has been updated from C:\adImg\img with ^($items.Count^) images!" -ForegroundColor Cyan
echo.
echo # 3. Start Lightweight CORS HTTP Server root at C:\adImg
echo $listener = New-Object System.Net.HttpListener
echo $listener.Prefixes.Add^("http://*:%PORT%/"^)
echo $listener.Start^()
echo Write-Host "--------------------------------------------------" -ForegroundColor Green
echo Write-Host "  Local Server Running on http://%IP_ADDR%:%PORT%  " -ForegroundColor Green
echo Write-Host "--------------------------------------------------" -ForegroundColor Green
echo Write-Host "Keep this window OPEN. Press Ctrl+C to stop."
echo.
echo while ^($listener.IsListening^) {
echo     $context = $listener.GetContext^()
echo     $request = $context.Request
echo     $response = $context.Response
echo     $response.Headers.Add^("Access-Control-Allow-Origin", "*"^)
echo     $response.Headers.Add^("Access-Control-Allow-Methods", "GET, POST, OPTIONS"^)
echo     $filePath = Join-Path "C:\adImg" $request.Url.LocalPath.TrimStart^('/')
echo     if ^(Test-Path $filePath -PathType Leaf^) {
echo         $bytes = [System.IO.File]::ReadAllBytes^($filePath^)
echo         $response.OutputStream.Write^($bytes, 0, $bytes.Length^)
echo     } else {
echo         $response.StatusCode = 404
echo     }
echo     $response.Close^()
echo }
) > "%PS_SCRIPT%"

echo [3/3] Executing Server Infrastructure...
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"
pause