@echo off
REM ============================================================
REM  forjaX - inyector X-Ray en Forja (port de cs2-rayoX)
REM
REM  Uso:
REM    build.bat          -> ejecuta el inyector (requiere CS2
REM                          abierto y ejecutar como Administrador)
REM    build.bat compilar -> genera forjaX.exe autonomo
REM ============================================================
setlocal

REM Ruta al repositorio de Forja (donde vive el binario forja.exe)
set "FORJA_DIR=C:\Users\gaucho\forja"

REM IMPORTANTE: se usa SIEMPRE el binario DEBUG. Si existiera un
REM release viejo, fallaria con funciones nativas faltantes
REM (ej: _imprimir_stdout no definida). El debug tiene todas las
REM nativas de forjaX.
set "FORJA=%FORJA_DIR%\target\debug\forja.exe"

if not exist "%FORJA%" (
    echo [ERROR] No se encontro forja.exe en "%FORJA_DIR%\target\debug"
    echo Compilalo primero:
    echo   cd /d "%FORJA_DIR%"
    echo   cargo build --bin forja
    exit /b 1
)

if "%1"=="compilar" (
    echo [OK] Compilando forjaX.exe ...
    "%FORJA%" compilar "%~dp0main.fa" -o "%~dp0forjaX.exe"
    exit /b %errorlevel%
)

echo [OK] Ejecutando inyector con: %FORJA%
"%FORJA%" ejecutar "%~dp0main.fa"

:fin
endlocal
