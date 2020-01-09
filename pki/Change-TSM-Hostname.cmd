
cd "C:\Program Files\tivoli\tsm\baclient\"

powershell -Command "(gc dsm.opt) -replace 'TCPSERVERADDRESS.*tsm1.cloud.ipnett.se', 'TCPSERVERADDRESS tsm1.backup.sto2.safedc.net' | Out-File -encoding ASCII dsm.opt.edited"

