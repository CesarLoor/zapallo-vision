# ZapalloAI - Script de instalacion y prueba
$ErrorActionPreference = "Stop"
$adb = "C:\Users\csar_\AppData\Local\Android\Sdk\platform-tools\adb.exe"
$apk = "C:\Users\csar_\Desktop\prototipo_zapallo\zapallo_app\build\app\outputs\flutter-apk\app-debug.apk"
$pkg = "com.espe.zapalloai.zapallo_app"

Write-Host "=== ZapalloAI - Instalacion ===" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar dispositivo
Write-Host "[1] Buscando dispositivo..." -ForegroundColor Yellow
& $adb start-server | Out-Null
$devices = & $adb devices | Select-String -Pattern "device$" 
if (-not $devices) {
    Write-Host "    ERROR: No hay dispositivo conectado" -ForegroundColor Red
    Write-Host ""
    Write-Host "    Pasos para conectar el Samsung S936B:" -ForegroundColor Yellow
    Write-Host "    1. En el telefono: Ajustes > Opciones de desarrollador > Depuracion USB: ON" 
    Write-Host "    2. Conectar cable USB al PC"
    Write-Host "    3. En el telefono, autorizar la depuracion (RSA fingerprint)"
    Write-Host "    4. Si no aparece, instalar driver Samsung USB desde:"
    Write-Host "       https://developer.samsung.com/android-usb-driver"
    Write-Host "    5. Alternativa: Habilitar depuracion inalambrica en el telefono"
    Write-Host "       y conectar via WiFi (Settings > Developer > Wireless debugging)"
    exit 1
}
$device = $devices[0].Line.Split("`t")[0]
Write-Host "    Dispositivo: $device" -ForegroundColor Green

# 2. Verificar app instalada
Write-Host ""
Write-Host "[2] Verificando instalacion previa..." -ForegroundColor Yellow
$installed = & $adb -s $device shell pm list packages $pkg
if ($installed) {
    Write-Host "    Desinstalando version anterior..." 
    & $adb -s $device uninstall $pkg | Out-Null
}

# 3. Instalar APK
Write-Host ""
Write-Host "[3] Instalando APK..." -ForegroundColor Yellow
$installResult = & $adb -s $device install -r -t $apk 2>&1
Write-Host "    $installResult" -ForegroundColor Green

# 4. Iniciar app
Write-Host ""
Write-Host "[4] Iniciando app..." -ForegroundColor Yellow
& $adb -s $device shell am start -n "$pkg/.MainActivity" | Out-Null
Start-Sleep -Seconds 3

# 5. Capturar logs
Write-Host ""
Write-Host "[5] Capturando logs (presiona Ctrl+C para detener)..." -ForegroundColor Yellow
Write-Host "    Filtrando: E/tflite, I/flutter, AndroidRuntime" -ForegroundColor Gray
& $adb -s $device logcat -c
& $adb -s $device logcat | Select-String -Pattern "tflite|flutter|AndroidRuntime|zapallo"
