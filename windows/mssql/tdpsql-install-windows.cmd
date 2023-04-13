@echo off
:: ******************************************************
:: * Safespring cloud Solution 
:: * IBM Storage Defender MS SQL install
:: * version 0.1 
:: * syntax:
:: * tdpsql-install-windows NODENAME PASSWORD

:: * Settings
set trgt_path=%PROGRAMFILES%\tivoli\tsm
set inst_log_dir=%TEMP%
set inst_log=TSMINST.LOG

:: * Sanity checks.
:: * Check commandline args
set TASK=CHECK_CMD_ARG1_MISSING
IF [%1] EQU [] ( Echo Problem: %TASK% & goto Error)
set TSM_NODENAME=%1
set TASK=CHECK_CMD_ARG2_MISSING
IF [%2] EQU [] ( Echo Problem: %TASK% & goto Error)
set TSM_PASS=%2

:: Create services that uses the generated password
SET TDP_CONFIG=%trgt_path%\tdpsql\dsm.opt

:: Collecting working directories
set BASE_DIR=%cd%
c:
cd %trgt_path%\baclient

:: start to clean out the old services (if any)
dsmcutil remove /name:"TSM MSSQL Scheduler"
dsmcutil remove /name:"TSM MSSQL Acceptor"

:: Create services for the new environment
dsmcutil install scheduler /name:"TSM MSSQL Scheduler" /node:%TSM_NODENAME% /optfile:"%TDP_CONFIG%" /password:%TSM_PASS% /autostart:no /startnow:no
dsmcutil install cad /name:"TSM MSSQL Acceptor" /node:%TSM_NODENAME% /password:%TSM_PASS% /optfile:"%TDP_CONFIG%" /autostart:yes /startnow:no
dsmcutil update cad /name:"TSM MSSQL Acceptor" /cadschedname:"TSM MSSQL Scheduler"

:: Now were done start service.
dsmcutil list
net start "TSM MSSQL Acceptor"

:: Changing back to working directory
cd %BASE_DIR% 

goto end

:Error 
:: * error handling goes here 
echo %TASK% failed >> %instlog_dir%\%inst_log%

:end
