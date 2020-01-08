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

@echo on
del "C:\Program Files\Tivoli\TSM\baclient\dsmcert.*"
%GSK8CAPICMD% -keydb -create -db %KDB% -pw %PASSWORD% -stash
%GSK8CAPICMD% -cert -add -db %KDB% -label "IPnett Cloud Root CA" -file IPnett-Cloud-Root-CA.pem -format ascii -stashed
%GSK8CAPICMD% -cert -list -db %KDB% -stashed
@echo off

:: Avoid exploding path on multiple invocations in the same command prompt window
set PATH=%ORIGPATH%
