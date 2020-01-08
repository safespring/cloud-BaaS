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
@echo>> SafeDC-Net-CA.pem -----BEGIN CERTIFICATE-----
@echo>> SafeDC-Net-CA.pem MIIEBTCCAu2gAwIBAgIBADANBgkqhkiG9w0BAQsFADBfMQswCQYDVQQGEwJTRTET
@echo>> SafeDC-Net-CA.pem MBEGA1UECgwKU2FmZWRjLm5ldDEeMBwGA1UECwwVRGF0YWNlbnRlciBPcGVyYXRp
@echo>> SafeDC-Net-CA.pem b25zMRswGQYDVQQDDBJTYWZlZGMubmV0IFJvb3QgQ0EwHhcNMTgwMjIwMjE1NjQ2
@echo>> SafeDC-Net-CA.pem WhcNMzgwMjE1MjE1NjQ2WjBfMQswCQYDVQQGEwJTRTETMBEGA1UECgwKU2FmZWRj
@echo>> SafeDC-Net-CA.pem Lm5ldDEeMBwGA1UECwwVRGF0YWNlbnRlciBPcGVyYXRpb25zMRswGQYDVQQDDBJT
@echo>> SafeDC-Net-CA.pem YWZlZGMubmV0IFJvb3QgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
@echo>> SafeDC-Net-CA.pem AQDdLQn+gKG8FA825nBgQNwsdMTG6nnm0qVvwGHYawmtcUzDHHOveQGV3p94pN1C
@echo>> SafeDC-Net-CA.pem HBsHsDa/WUEjF2nN2nr7NhX42F8d6HX3EwlK0OEhVF0OyBsfDLyr5mMaLeHJe2aj
@echo>> SafeDC-Net-CA.pem qgLVthkRLJEzAV2LcQtzWsaRCAaNklPXB57E4y/SE0zM1PbQcGH32NsAstbXPchZ
@echo>> SafeDC-Net-CA.pem KDNWsagfcXsKZk96El7UWY0Q9HGtqjQuGAYnGyFAnPul7c5uWzv5pyN/S+aRHQN8
@echo>> SafeDC-Net-CA.pem mhrHCd7fxdwTtjwEZAEqm+SKtXLG6t+4aqaUC4ubYg7MVuScUQ6r58E0U90ckkba
@echo>> SafeDC-Net-CA.pem TtciHJiGM2rfYiKVUh29nPTdAgMBAAGjgcswgcgwDwYDVR0TAQH/BAUwAwEB/zAd
@echo>> SafeDC-Net-CA.pem BgNVHQ4EFgQUDDhvUQKo/6s3swD2A1zJmi2N2oQwgYgGA1UdIwSBgDB+gBQMOG9R
@echo>> SafeDC-Net-CA.pem Aqj/qzezAPYDXMmaLY3ahKFjpGEwXzELMAkGA1UEBhMCU0UxEzARBgNVBAoMClNh
@echo>> SafeDC-Net-CA.pem ZmVkYy5uZXQxHjAcBgNVBAsMFURhdGFjZW50ZXIgT3BlcmF0aW9uczEbMBkGA1UE
@echo>> SafeDC-Net-CA.pem AwwSU2FmZWRjLm5ldCBSb290IENBggEAMAsGA1UdDwQEAwIBhjANBgkqhkiG9w0B
@echo>> SafeDC-Net-CA.pem AQsFAAOCAQEAUhnRfJHRBTOcnEbWg6M6YyhdzzUYZcYO7SgCG8VbxmhbZpjcfQWJ
@echo>> SafeDC-Net-CA.pem eHVGcgR/RuYKI5N7PEU8bRQwo4GtNBxVU4rEpCNRx5lNEjjF9eqCpe22XidEAeTw
@echo>> SafeDC-Net-CA.pem mbg2vYt+pQwbcI6ylRex6pPB4uZJEh9NfpreOKDSe6GYnYr/URmQQo6ql1rCL+to
@echo>> SafeDC-Net-CA.pem wj+3pbvsxGBicoQzrIBiFH3/9BBb/IxIuPv60hwF4SH0MEX3GQYfuhZIAbac0Rgs
@echo>> SafeDC-Net-CA.pem UIkB6BcgUqSpQVbXIgwu7Olhn6jjAZPB2GmtbndJiqasqYwwwexYJ7yW4Kfpq3eq
@echo>> SafeDC-Net-CA.pem KYLtlCxXjKK44dISRdi6hXQdBEZF/6QWAQ==
@echo>> SafeDC-Net-CA.pem -----END CERTIFICATE-----

@echo on
del "C:\Program Files\Tivoli\TSM\baclient\dsmcert.*"
%GSK8CAPICMD% -keydb -create -db %KDB% -pw %PASSWORD% -stash
%GSK8CAPICMD% -cert -add -db %KDB% -label "Safedc Net Root CA" -file SafeDC-Net-CA.pem -format ascii -stashed
%GSK8CAPICMD% -cert -list -db %KDB% -stashed
@echo off

:: Avoid exploding path on multiple invocations in the same command prompt window
set PATH=%ORIGPATH%
