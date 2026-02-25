@echo off
setlocal enabledelayedexpansion

set CONTAINER_NAME=localstack-server
set IMAGE=localstack/localstack:latest
set PORT_EDGE=4566
set VOLUME_DIR=%USERPROFILE%\.localstack

echo ========================================
echo LocalStack Docker Runner - Windows
echo ========================================
echo.

:: Detectar IPs da maquina
echo Detectando IPs da maquina...
set HOSTNAME=%COMPUTERNAME%

echo.
echo Hostname: %HOSTNAME%
echo IPs disponiveis:
for /f "tokens=14" %%a in ('ipconfig ^| findstr IPv4') do echo %%a
echo.

:: Criar diretorio persistente
if not exist "%VOLUME_DIR%" (
    mkdir "%VOLUME_DIR%"
)

:: Remover container antigo se existir (suprimindo erros se nao existir)
echo Removendo container antigo...
docker rm -f %CONTAINER_NAME% >nul 2>&1

echo.
echo Iniciando LocalStack...
echo.

:: O acento circunflexo (^) e usado para quebra de linha no Batch
docker run -d ^
    --name %CONTAINER_NAME% ^
    --restart unless-stopped ^
    -p 0.0.0.0:%PORT_EDGE%:4566 ^
    -e DEBUG=1 ^
    -e LOCALSTACK_HOST=0.0.0.0 ^
    -e GATEWAY_LISTEN=0.0.0.0:4566 ^
    -v "%VOLUME_DIR%:/var/lib/localstack" ^
    -v /var/run/docker.sock:/var/run/docker.sock ^
    %IMAGE%

echo.
echo ========================================
echo LocalStack iniciado com sucesso!
echo ========================================
echo.

echo Acesso local:
echo http://localhost:%PORT_EDGE%
echo.

echo Ver logs:
echo docker logs -f %CONTAINER_NAME%
echo.
echo Parar:
echo docker stop %CONTAINER_NAME%