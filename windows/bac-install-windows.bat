@echo off
:: ******************************************************
:: * TSM IPnett cloud Solution 
:: * TSM client install
:: * version 0.1 
:: * syntax:
:: * tsm_inst TSM_NODENAME TSM_CLIENT_PASSWORD

:: * Settings
set src_path=c:\tsm_images
set tsm_msi="IBM Tivoli Storage Manager Client.msi"
set trgt_path=%PROGRAMFILES%\tivoli\tsm
set acrch=%PROCESSOR_ARCHITECTURE%
set inst_log_dir=%TEMP%
set inst_log=TSMINST.LOG

::SET PASSWORD=mekmitasdigoat
SET KDB=%trgt_path%\baclient\dsmcert.kdb
:: save working directory
SET CURRDIR=%CD%
c:
cd %trgt_path%\baclient

:: Check 32 or 64 bit for gsk8kit 
set gskcmd=gsk8capicmd
if (ARCH EQU AMD64) (set gskcmd=gsk8capicmd_64)

:: * Sanity checks.
:: * Check commandline args
set TASK=CHECK_CMD_ARG1_MISSING
IF [%1] EQU [] ( Echo Problem: %TASK% & goto Error)
set TSM_NODENAME=%1
set TASK=CHECK_CMD_ARG2_MISSING
IF [%2] EQU [] ( Echo Problem: %TASK% & goto Error)
set TSM_PASS=%2

:: * Check the Certificate location
:: * Check the MSI location 

:: * install Vcredistributables 32 bit
Set TASK=Installing_VCREDIST32
if NOT (ARCH EQU AMD64) (vcredist_x86.exe /q /c:"msiexec /i vcredist.msi /qn /l*v %inst_log_dir%\vcredist_x86.log")
if %ERRORLEVEL% GTR 0 ( Echo Problem: %TASK% & goto Error)

:: * install Vcredistributables 64 bit
Set TASK=Installing_VCREDIST64_1
if (ARCH EQU AMD64) (vcredist_x86.exe /q /c:"msiexec /i vcredist.msi /qn /l*v %inst_log_dir%\vcredist_x86.log")
Set TASK=Installing_VCREDIST64_2
if (ARCH EQU AMD64) (vcredist_x64.exe /q /c:"msiexec /i vcredist.msi /qn /l*v %inst_log_dir%\vcredist_x64.log")
if %ERRORLEVEL% GTR 0 ( Echo Problem: %TASK% & goto Error)

:: * install TSM client  32 bit
Set TASK=Installing_TSM_CLIENT32
if NOT (ARCH EQU AMD64) (msiexec /i %src_path%\%tsm_msi% RebootYesNo="No" REBOOT="Suppress" ALLUSERS=1 INSTALLDIR=%trgt_path% ADDLOCAL="BackupArchiveGUI,BackupArchiveWeb,ApiRuntime,AdministrativeCmd" TRANSFORMS=1033.mst /qn /l*v "%inst_log_dir%\log.txt") 
if %ERRORLEVEL% GTR 0 ( Echo Problem: %TASK% & goto Error)
:: * install TSM client 64 bit
Set TASK=Installing_TSM_CLIENT32
if (ARCH EQU AMD64) (msiexec /i %src_path%\%tsm_msi% RebootYesNo="No" REBOOT="Suppress" ALLUSERS=1 INSTALLDIR=%trgt_path% ADDLOCAL="BackupArchiveGUI,BackupArchiveWeb,Api64Runtime,AdministrativeCmd" TRANSFORMS=1033.mst /qn /l*v "%inst_log_dir%\log.txt")
if %ERRORLEVEL% GTR 0 ( Echo Problem: %TASK% & goto Error)
:: * Configure SSL
Set TASK=Configuring_SSL 

:: Move the old keystore
RENAME %KDB% %KDB%.NOTIPNETT
:: Save the path variable 
SET ORG_PATH=%PATH%

set PATH=%PATH%;c:\Program Files\Common Files\Tivoli\TSM\api64\gsk8\bin\;c:\Program Files\Common Files\Tivoli\TSM\api64\gsk8\lib64\;C:\Program Files\Common Files\Tivoli\TSM\api\gsk8\bin;C:\Program Files\Common Files\Tivoli\TSM\api\gsk8\lib
c:
cd %trgt_path%\baclient

@echo >IPnett-Cloud-Root-CA.pem
@echo >> IPnett-Cloud-Root-CA.pem -----BEGIN CERTIFICATE-----
@echo >> IPnett-Cloud-Root-CA.pem MIIFXjCCA0agAwIBAgIJAIg4TlVTvkplMA0GCSqGSIb3DQEBCwUAMF8xHDAaBgNV
@echo >> IPnett-Cloud-Root-CA.pem BAMTE0lQbmV0dCBCYWFTIFJvb3QgQ0ExHjAcBgNVBAsTFUlQbmV0dCBDbG91ZCBT
@echo >> IPnett-Cloud-Root-CA.pem ZXJ2aWNlczESMBAGA1UEChMJSVBuZXR0IEFCMQswCQYDVQQGEwJTRTAeFw0xNDA5
@echo >> IPnett-Cloud-Root-CA.pem MDExNjM1MjFaFw0yNTA4MTQxNjM1MjFaMF8xHDAaBgNVBAMTE0lQbmV0dCBCYWFT
@echo >> IPnett-Cloud-Root-CA.pem IFJvb3QgQ0ExHjAcBgNVBAsTFUlQbmV0dCBDbG91ZCBTZXJ2aWNlczESMBAGA1UE
@echo >> IPnett-Cloud-Root-CA.pem ChMJSVBuZXR0IEFCMQswCQYDVQQGEwJTRTCCAiIwDQYJKoZIhvcNAQEBBQADggIP
@echo >> IPnett-Cloud-Root-CA.pem ADCCAgoCggIBALAy5JCStoJ10Ffj4kpUM9roOTeFMTa67flizsC4OhwMz+aTwwax
@echo >> IPnett-Cloud-Root-CA.pem xwzqcsKYH+Wc47rRabE7R98GE9TpgxGIQtxrh6nNy5htiFK+x2/Nj+dLhluqLCer
@echo >> IPnett-Cloud-Root-CA.pem kCNxWUN1RhPWjOGSTDZzjWcavolfnDuNiR9/JBGUed9oFY+oCFE6OVgI92wwOk9X
@echo >> IPnett-Cloud-Root-CA.pem KP0nKkaX+vpDR3z3rm6wdSvtLnRuFlpTmo/sgawcCOq6/V3BXXZBhXrML34DUvWE
@echo >> IPnett-Cloud-Root-CA.pem 08rGu4wT0LdCTuzGfArDdv9xxY6etI22FFe8u4FYIoPt+oq2uUut0IpOzTDCH6KR
@echo >> IPnett-Cloud-Root-CA.pem UXnnvVjwW9UJ/N4r8Uta3IgEp+xDnKCiDQ0wapn4gOosJceJpY4D5EAaCH2sYqsn
@echo >> IPnett-Cloud-Root-CA.pem 5vTLZTNyXioVjNN/tRN4PUJjsy38SSCONcp1V9b1LR7w6S8zBVJ6uwELvlTU6ugi
@echo >> IPnett-Cloud-Root-CA.pem IBBSD3qSXSWw/rUw7yxaZSP/aKL7tJMkI5j6X/aesuQhRXl4FRpa+73BYNkNWexH
@echo >> IPnett-Cloud-Root-CA.pem st+D6vDz1m6g441ujUNoJ2UMF7NVwGpeSOkRvMofhkNPkwMqX8ZR43jo5A66O0hm
@echo >> IPnett-Cloud-Root-CA.pem Gwm4Y/OlntEXBTHXnZx6gQw7nWQMtV5HMefvTqLIlfXw74WRGCF1NtSgrq/yYRxR
@echo >> IPnett-Cloud-Root-CA.pem fyDpRAxxUrLyhXzI03AXF0+zAt3KvuEqPabQzpiOfe67ezValoQ2ITCzAgMBAAGj
@echo >> IPnett-Cloud-Root-CA.pem HTAbMAwGA1UdEwQFMAMBAf8wCwYDVR0PBAQDAgEGMA0GCSqGSIb3DQEBCwUAA4IC
@echo >> IPnett-Cloud-Root-CA.pem AQBfUoG5Y4XM+XaDpVj7phz4zEgjHd9Sekt0l9HscKSblRfB1UF3BM1wLJuZZZbC
@echo >> IPnett-Cloud-Root-CA.pem XQU80KarjLhtmZmk+UIlC8WUTBK2/OM94ZtFbAMQUaMuSF1LU1LjbaFrRaaundmS
@echo >> IPnett-Cloud-Root-CA.pem I3hnciEwSHGD3xyMeViHr/Zr9WxUjj2x3osZU8Ud+QdzPrFX1iMzYbhgx8G43DNa
@echo >> IPnett-Cloud-Root-CA.pem 0oXptYfFdpvd8XkH6BhGDOvEB/yb95prugE8aBLOFLvnAkKj8mEHVo+jpM2TViTJ
@echo >> IPnett-Cloud-Root-CA.pem 51eMjI7p8/ukw0Efy6BdS3WtAI3ZVz/35T4ugCN717KCUha7ndkCM5RkJeTetQjW
@echo >> IPnett-Cloud-Root-CA.pem 8uSSVMtIG63ajkx8S7GC5lguDSTslqHgwwZl7QkuHqvJrHsukS0pMAB5JApmUT8S
@echo >> IPnett-Cloud-Root-CA.pem 8am11JRO1cJ1EmNJG2ltM8cv+25y7QPMoyX3yElI0GOeM7P3DR08+t/JccL/2Dh2
@echo >> IPnett-Cloud-Root-CA.pem dLDsLqq69WviD7skU0Aus/ffkyS7Dm8IOWdk3s9o9LYgBO8G7/iNd+TRCvwOMJh4
@echo >> IPnett-Cloud-Root-CA.pem lWTFmiP7pCTWqorxAM2maHalQwu/DCBoCHasjcHwoEm9Fi08XYqbI4JpfFmxgRrL
@echo >> IPnett-Cloud-Root-CA.pem 3ab3tLwFFQHv5G3IxF7bjGFyz/4grm1Hkp/jSfc0Jon/BaWy7XkAxoNZ2c/wUsOM
@echo >> IPnett-Cloud-Root-CA.pem rtBXUyt93noHEST3jGFE2vz1P0hjR5n8eCcrXEYGeaxaxQ==
@echo >> IPnett-Cloud-Root-CA.pem -----END CERTIFICATE-----

:: * Create the keystore
%gskcmd% -keydb -create -populate -db %KDB% -pw %TSM_PASS% -stash
:: * Insert the certificate in the keystore
%gskcmd% -cert -add -db %KDB% -label "IPnett BaaS Root CA" -file %CURRDIR%\IPnett-Cloud-Root-CA.pem -format ascii -stashed 
:: *The following line can be used to verify the SSL Cert installation
:: gsk8capicmd_64 -cert -list -db %KDB% -stashed

:: Reset the path variable
SET ORG_PATH=%PATH%

if %ERRORLEVEL% GTR 0 ( Echo Problem: %TASK% & goto Error)

:: * Set and store the password in the registry 
dsmc set password %TSM_PASS% %TSM_PASS% %TSM_PASS%

:: Create services that uses the generated password
:: Once the BA client is installed some defaults are used.
SET DSM_DIR=%trgt_path%\baclient
SET DSM_LOG=%trgt_path%\baclient
SET DSM_CONFIG=%trgt_path%\baclient\dsm.opt

SET PASSWD=%TSM_PASS%
SET PATH=%PATH%;%DSM_DIR%
c:
cd %trgt_path%\baclient

:: start to clean out the old services (if any)
dsmcutil remove /name:"TSM Client Scheduler"
dsmcutil remove /name:"TSM Client Acceptor"
dsmcutil remove /name:"TSM Remote Agent"
::dsmcutil list

:: Here some magic find if nodename is set to something else than default
for /f "tokens=1,2" %%i in ('findstr /I /B node dsm.opt') do set NODE=%%j
if not defined NODE set NODE=%computername%

::rem create services for the new environment
dsmcutil install scheduler /name:"TSM Client Scheduler" /node:%NODE% /optfile:"%DSM_CONFIG%" /password:%PASSWD% /autostart:no /startnow:no
dsmcutil install cad /name:"TSM Client Acceptor" /node:%NODE% /password:%PASSWD% /optfile:"%DSM_CONFIG%" /autostart:yes /startnow:no
dsmcutil install remoteagent /name:"TSM Remote Agent" /node:%NODE% /password:%PASSWD% /optfile:"%DSM_CONFIG%" /partnername:"TSM Client Acceptor" /startnow:no
dsmcutil update cad /name:"TSM Client Acceptor" /cadschedname:"TSM Client Scheduler"

:: Now were done start service.
dsmcutil list
net start "TSM Client Acceptor"
goto end

:Error 
:: * error handling goes here 
echo %TASK% failed >> %instlog_dir%\%inst_log%

:end
