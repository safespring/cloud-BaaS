@echo off
:: ******************************************************
:: * TSM IPnett cloud Solution 
:: * TSM client install
:: * version 0.1 
:: * syntax:
:: * tsm_inst TSM_CLIENT_PASSWORD

:: * Settings
c:
set src_path=c:\tsm_images
set tsm_msi="IBM Tivoli Storage Manager Client.msi"
set trgt_path=%PROGRAMFILES%\tivoli\tsm"
set acrch=%PROCESSOR_ARCHITECTURE%
set inst_log_dir=%TEMP%
set inst_log=TSMINST.LOG

::SET PASSWORD=mekmitasdigoat
SET KDB=%trgt_path%\baclient\dsmcert.kdb
cd %trgt_path%\\baclient"

:: Check 32 or 64 bit for gsk8kit 
set gskcmd=gsk8capicmd
if (ARCH EQU AMD64) (set gskcmd=gsk8capicmd_64)

:: * Sanity checks.
:: * Check commandline args
set TASK=CHECK_CMD_ARG_MISSING
IF [%1] EQU [] ( Echo Problem: %TASK% & goto Error)
set TSM_PASS=%1

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
Mv %KDB% %KDB%.NOTIPNETT
:: Save the path variable 
SET ORG_PATH=%PATH%

set PATH=%PATH%;c:\Program Files\Common Files\Tivoli\TSM\api64\gsk8\bin\;c:\Program Files\Common Files\Tivoli\TSM\api64\gsk8\lib64\;C:\Program Files\Common Files\Tivoli\TSM\api\gsk8\bin;C:\Program Files\Common Files\Tivoli\TSM\api\gsk8\lib
cd %trgt_path%\baclient"
:: * Create the keystore
%gskcmd% -keydb -create -populate -db %KDB% -pw %TSM_PASS% -stash
:: * Insert the certificate in the keystore
%gskcmd% -cert -add -db %KDB% -label "IPnett BaaS Root CA" -file IPnett-Cloud-Root-CA.pem -format ascii -stashed 
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
