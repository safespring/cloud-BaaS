
@cd "C:\Program Files\tivoli\tsm\baclient\"

powershell -Command "(gc dsm.opt) -replace 'TCPSERVERADDRESS.*tsm1.cloud.ipnett.se', 'TCPSERVERADDRESS tsm1.backup.sto2.safedc.net' | Out-File -encoding ASCII dsm.opt.edited"
@echo "Please verify changes to C:\Program Files\tivoli\tsm\baclient\dsm.opt.edited"
@echo "looks ok and copy it over dsm.opt and restart TSM services"
