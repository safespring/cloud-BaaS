
powershell -Command "(gc C:\Program Files\tivoli\tsm\baclient\bin\dsm.opt) -replace 'TCPSERVERADDRESS.*tsm1.cloud.ipnett.se', 'TCPSERVERADDRESS tsm1.backup.sto2.safedc.net' | Out-File -encoding ASCII C:\Program Files\tivoli\tsm\baclient\bin\dsm.opt.edited"

