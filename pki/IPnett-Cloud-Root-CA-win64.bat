@echo off
:: Installation script for PEM-file into default TSM installation folders.
:: Requires script to be executed in directory with permissions.
:: Upon successful completion, the script leaves a PEM file in this folder for transparency reasons.
:: This PEM file is not required by the service as it has been inserted into the GSK Trust Database

:: Set this PASSWORD string with some random secret, this random secret is one-time and not necessary to remember.
:: The program won't run unless you have done this.
PASSWORD=""
if [%PASSWORD%] equ [] ( echo "No password set.  Please set a random password" & exit)

KDB="C:\Program Files\Tivoli\TSM\baclient\dsmcert.kdb"
GSK8CAPICMD="C:\Program Files\Common Files\Tivoli\TSM\api64\gsk8\bin\gsk8capicmd_64"

:: Write out PEM-file into PEM-file-name into the Current Directory
@echo >  IPnett-Cloud-Root-CA.pem -----BEGIN CERTIFICATE-----
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


%GSK8CAPICMD% -keydb -create -db %KDB% -pw %PASSWORD% -stash
%GSK8CAPICMD% -cert -add -db %KDB% -label "IPnett BaaS Root CA" -file IPnett-Cloud-Root-CA.pem -format ascii -stashed
%GSK8CAPICMD% -cert -list -db %KDB% -stashed
