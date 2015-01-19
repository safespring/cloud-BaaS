@echo off

:: replace PASSWORD string with some random secret (that you know)
PASSWORD=MoghooNaeFie5sipi9aegheixiNg5che

KDB="C:\Program Files\Tivoli\TSM\baclient\dsmcert.kdb"
GSK8CAPICMD="C:\Program Files\Common Files\Tivoli\TSM\api\gsk8\bin\gsk8capicmd"

del "C:\Program Files\Tivoli\TSM\baclient\dsmcert.*"
%GSK8CAPICMD% -keydb -create -db %KDB% -pw %PASSWORD% -stash
%GSK8CAPICMD% -cert -add -db %KDB% -label "IPnett Cloud Root CA" -file IPnett-Cloud-Root-CA.pem -format ascii -stashed
%GSK8CAPICMD% -cert -add -db %KDB% -label "IPnett Cloud Legacy CA" -file IPnett-Cloud-Legacy-CA.pem -format ascii -stashed
%GSK8CAPICMD% -cert -list -db %KDB% -stashed
