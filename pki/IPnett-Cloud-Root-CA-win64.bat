@echo off
:: Installation script for PEM-file into default TSM installation folders.
:: Requires script to be executed in directory with permissions, and, requires write permissions to the KDB file below.
:: Typically, this implies that the script must be executed as administrator.
:: Upon successful completion, the script leaves a PEM file in this folder for transparency reasons.
:: This PEM file is not required by the service as it has been inserted into the GSK Trust Database
:: See more at http://pic.dhe.ibm.com/infocenter/tsminfo/v7r1/index.jsp?topic=%2Fcom.ibm.itsm.client.doc%2Ft_cfg_ssl.html

:: Set this PASSWORD string with some random secret, this random secret is one-time and not necessary to remember.
:: The program won't run unless you have done this.
set PASSWORD=REPLACEME
if [%PASSWORD%] equ [REPLACEME] ( 
	echo No password set.  Please set a random password. 
	exit /B
)

set KDB="C:\Program Files\Tivoli\TSM\baclient\dsmcert.kdb"
set GSK8CAPICMD=gsk8capicmd_64
set ORIGPATH=%PATH%
set PATH=%PATH%;C:\Program Files\Common Files\Tivoli\TSM\api64\gsk8\lib64;C:\Program Files\Common Files\Tivoli\TSM\api64\gsk8\bin

:: Write out PEM-file into PEM-file-name into the Current Directory
@echo>  IPnett-Cloud-Root-CA.pem -----BEGIN CERTIFICATE-----
@echo>> IPnett-Cloud-Root-CA.pem MIIECDCCAvCgAwIBAgIBADANBgkqhkiG9w0BAQsFADBgMQswCQYDVQQGEwJOTzES
@echo>> IPnett-Cloud-Root-CA.pem MBAGA1UECgwJSVBuZXR0IEFTMR4wHAYDVQQLDBVJUG5ldHQgQ2xvdWQgU2Vydmlj
@echo>> IPnett-Cloud-Root-CA.pem ZXMxHTAbBgNVBAMMFElQbmV0dCBDbG91ZCBSb290IENBMB4XDTE1MDExNTEzMjkz
@echo>> IPnett-Cloud-Root-CA.pem M1oXDTM1MDExMDEzMjkzM1owYDELMAkGA1UEBhMCTk8xEjAQBgNVBAoMCUlQbmV0
@echo>> IPnett-Cloud-Root-CA.pem dCBBUzEeMBwGA1UECwwVSVBuZXR0IENsb3VkIFNlcnZpY2VzMR0wGwYDVQQDDBRJ
@echo>> IPnett-Cloud-Root-CA.pem UG5ldHQgQ2xvdWQgUm9vdCBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
@echo>> IPnett-Cloud-Root-CA.pem ggEBAK8y5ni/lQvmMmIGMFCiTJhtKY7ErL7NpM7GyXziizZ0SfPOCsK2OcGN6+5i
@echo>> IPnett-Cloud-Root-CA.pem tRNbZee1e6wqK71GAokrjMzCZTzdS0n0qWREM4EUBbn9b5cCCUlr5E+SRrjU0oWq
@echo>> IPnett-Cloud-Root-CA.pem IcnMClsax26FJIXfro3m7gL6EJr5HENwwVZQg9FlCH4Xm/UHuspghTg2/2J3NYkj
@echo>> IPnett-Cloud-Root-CA.pem 5q5ybQaDwEI2L4hCoQUsWY6WzfLMYtOtcJ8bB5imeH/Eck2nxNfRfrfJYNZJQlx8
@echo>> IPnett-Cloud-Root-CA.pem ac1/iRgBwsC7I4/XJinVi97Zfr16yp2Xl3WDHItYhqM62sPaBTzMKZsQlR3XW2nY
@echo>> IPnett-Cloud-Root-CA.pem NomGExqALaCF5vkW/soT5hh56CUCAwEAAaOBzDCByTAPBgNVHRMBAf8EBTADAQH/
@echo>> IPnett-Cloud-Root-CA.pem MB0GA1UdDgQWBBTJmXRAhVP2425QZtqulPQcL61pyDCBiQYDVR0jBIGBMH+AFMmZ
@echo>> IPnett-Cloud-Root-CA.pem dECFU/bjblBm2q6U9BwvrWnIoWSkYjBgMQswCQYDVQQGEwJOTzESMBAGA1UECgwJ
@echo>> IPnett-Cloud-Root-CA.pem SVBuZXR0IEFTMR4wHAYDVQQLDBVJUG5ldHQgQ2xvdWQgU2VydmljZXMxHTAbBgNV
@echo>> IPnett-Cloud-Root-CA.pem BAMMFElQbmV0dCBDbG91ZCBSb290IENBggEAMAsGA1UdDwQEAwIBhjANBgkqhkiG
@echo>> IPnett-Cloud-Root-CA.pem 9w0BAQsFAAOCAQEAB8X8HjpGGUgdnyoS1j34EqeWu9RQxuM/JGMlE3JKgnBaAsd7
@echo>> IPnett-Cloud-Root-CA.pem 9+L0abJBZ8X48rTOn1IwtxXuE53xcDk+2BTL91Qn/eoZxUJJWzK0Ai/QxzaWMCrT
@echo>> IPnett-Cloud-Root-CA.pem 8N5Z8McEdCI2p5MS40HMrL4PODuWmt3lrxwVDUJRHCrj3M9+7U2Offgru8WKYjja
@echo>> IPnett-Cloud-Root-CA.pem 2EtJpW5t80M5BDEjzOkFeOCX+ySsHlZqFV92VdkkjATz7ti3mSbnaGJLfoF7YtHQ
@echo>> IPnett-Cloud-Root-CA.pem CWZGUzqLHYzNl1urLGK7aUO9qoNAKhn5HtShBfNVeDG7MbJIlg4gFqs4cIylpwY+
@echo>> IPnett-Cloud-Root-CA.pem Wb8FtMkMugL6jprYjO/dqTfaNN4EQA7x4ZafvQ==
@echo>> IPnett-Cloud-Root-CA.pem -----END CERTIFICATE-----

:: Write out PEM-file into PEM-file-name into the Current Directory
@echo>  IPnett-Cloud-Legacy-CA.pem -----BEGIN CERTIFICATE-----
@echo>> IPnett-Cloud-Legacy-CA.pem MIIFXjCCA0agAwIBAgIJAIg4TlVTvkplMA0GCSqGSIb3DQEBCwUAMF8xHDAaBgNV
@echo>> IPnett-Cloud-Legacy-CA.pem BAMTE0lQbmV0dCBCYWFTIFJvb3QgQ0ExHjAcBgNVBAsTFUlQbmV0dCBDbG91ZCBT
@echo>> IPnett-Cloud-Legacy-CA.pem ZXJ2aWNlczESMBAGA1UEChMJSVBuZXR0IEFCMQswCQYDVQQGEwJTRTAeFw0xNDA5
@echo>> IPnett-Cloud-Legacy-CA.pem MDExNjM1MjFaFw0yNTA4MTQxNjM1MjFaMF8xHDAaBgNVBAMTE0lQbmV0dCBCYWFT
@echo>> IPnett-Cloud-Legacy-CA.pem IFJvb3QgQ0ExHjAcBgNVBAsTFUlQbmV0dCBDbG91ZCBTZXJ2aWNlczESMBAGA1UE
@echo>> IPnett-Cloud-Legacy-CA.pem ChMJSVBuZXR0IEFCMQswCQYDVQQGEwJTRTCCAiIwDQYJKoZIhvcNAQEBBQADggIP
@echo>> IPnett-Cloud-Legacy-CA.pem ADCCAgoCggIBALAy5JCStoJ10Ffj4kpUM9roOTeFMTa67flizsC4OhwMz+aTwwax
@echo>> IPnett-Cloud-Legacy-CA.pem xwzqcsKYH+Wc47rRabE7R98GE9TpgxGIQtxrh6nNy5htiFK+x2/Nj+dLhluqLCer
@echo>> IPnett-Cloud-Legacy-CA.pem kCNxWUN1RhPWjOGSTDZzjWcavolfnDuNiR9/JBGUed9oFY+oCFE6OVgI92wwOk9X
@echo>> IPnett-Cloud-Legacy-CA.pem KP0nKkaX+vpDR3z3rm6wdSvtLnRuFlpTmo/sgawcCOq6/V3BXXZBhXrML34DUvWE
@echo>> IPnett-Cloud-Legacy-CA.pem 08rGu4wT0LdCTuzGfArDdv9xxY6etI22FFe8u4FYIoPt+oq2uUut0IpOzTDCH6KR
@echo>> IPnett-Cloud-Legacy-CA.pem UXnnvVjwW9UJ/N4r8Uta3IgEp+xDnKCiDQ0wapn4gOosJceJpY4D5EAaCH2sYqsn
@echo>> IPnett-Cloud-Legacy-CA.pem 5vTLZTNyXioVjNN/tRN4PUJjsy38SSCONcp1V9b1LR7w6S8zBVJ6uwELvlTU6ugi
@echo>> IPnett-Cloud-Legacy-CA.pem IBBSD3qSXSWw/rUw7yxaZSP/aKL7tJMkI5j6X/aesuQhRXl4FRpa+73BYNkNWexH
@echo>> IPnett-Cloud-Legacy-CA.pem st+D6vDz1m6g441ujUNoJ2UMF7NVwGpeSOkRvMofhkNPkwMqX8ZR43jo5A66O0hm
@echo>> IPnett-Cloud-Legacy-CA.pem Gwm4Y/OlntEXBTHXnZx6gQw7nWQMtV5HMefvTqLIlfXw74WRGCF1NtSgrq/yYRxR
@echo>> IPnett-Cloud-Legacy-CA.pem fyDpRAxxUrLyhXzI03AXF0+zAt3KvuEqPabQzpiOfe67ezValoQ2ITCzAgMBAAGj
@echo>> IPnett-Cloud-Legacy-CA.pem HTAbMAwGA1UdEwQFMAMBAf8wCwYDVR0PBAQDAgEGMA0GCSqGSIb3DQEBCwUAA4IC
@echo>> IPnett-Cloud-Legacy-CA.pem AQBfUoG5Y4XM+XaDpVj7phz4zEgjHd9Sekt0l9HscKSblRfB1UF3BM1wLJuZZZbC
@echo>> IPnett-Cloud-Legacy-CA.pem XQU80KarjLhtmZmk+UIlC8WUTBK2/OM94ZtFbAMQUaMuSF1LU1LjbaFrRaaundmS
@echo>> IPnett-Cloud-Legacy-CA.pem I3hnciEwSHGD3xyMeViHr/Zr9WxUjj2x3osZU8Ud+QdzPrFX1iMzYbhgx8G43DNa
@echo>> IPnett-Cloud-Legacy-CA.pem 0oXptYfFdpvd8XkH6BhGDOvEB/yb95prugE8aBLOFLvnAkKj8mEHVo+jpM2TViTJ
@echo>> IPnett-Cloud-Legacy-CA.pem 51eMjI7p8/ukw0Efy6BdS3WtAI3ZVz/35T4ugCN717KCUha7ndkCM5RkJeTetQjW
@echo>> IPnett-Cloud-Legacy-CA.pem 8uSSVMtIG63ajkx8S7GC5lguDSTslqHgwwZl7QkuHqvJrHsukS0pMAB5JApmUT8S
@echo>> IPnett-Cloud-Legacy-CA.pem 8am11JRO1cJ1EmNJG2ltM8cv+25y7QPMoyX3yElI0GOeM7P3DR08+t/JccL/2Dh2
@echo>> IPnett-Cloud-Legacy-CA.pem dLDsLqq69WviD7skU0Aus/ffkyS7Dm8IOWdk3s9o9LYgBO8G7/iNd+TRCvwOMJh4
@echo>> IPnett-Cloud-Legacy-CA.pem lWTFmiP7pCTWqorxAM2maHalQwu/DCBoCHasjcHwoEm9Fi08XYqbI4JpfFmxgRrL
@echo>> IPnett-Cloud-Legacy-CA.pem 3ab3tLwFFQHv5G3IxF7bjGFyz/4grm1Hkp/jSfc0Jon/BaWy7XkAxoNZ2c/wUsOM
@echo>> IPnett-Cloud-Legacy-CA.pem rtBXUyt93noHEST3jGFE2vz1P0hjR5n8eCcrXEYGeaxaxQ==
@echo>> IPnett-Cloud-Legacy-CA.pem -----END CERTIFICATE-----

@echo on
del "C:\Program Files\Tivoli\TSM\baclient\dsmcert.*"
%GSK8CAPICMD% -keydb -create -db %KDB% -pw %PASSWORD% -stash
%GSK8CAPICMD% -cert -add -db %KDB% -label "IPnett Cloud Root CA" -file IPnett-Cloud-Root-CA.pem -format ascii -stashed
%GSK8CAPICMD% -cert -add -db %KDB% -label "IPnett Legacy Root CA" -file IPnett-Cloud-Legacy-CA.pem -format ascii -stashed
%GSK8CAPICMD% -cert -list -db %KDB% -stashed
@echo off

:: Avoid exploding path on multiple invocations in the same command prompt window
set PATH=%ORIGPATH%