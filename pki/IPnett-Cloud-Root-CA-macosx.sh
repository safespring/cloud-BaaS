#!/bin/sh

# replace PASSWORD string with some random secret (that you know)
PASSWORD=MoghooNaeFie5sipi9aegheixiNg5che

KDB="/Library/Application Support/tivoli/tsm/client/ba/bin/dsmcert.db"
GSK8CAPICMD=/Library/ibm/gsk8/bin/gsk8capicmd

$GSK8CAPICMD -keydb -create -db "$KDB" -pw "$PASSWORD" -stash

$GSK8CAPICMD -cert -add -db "$KDB" -format ascii -stashed \
    -label "IPnett BaaS Root CA" \
    -file /tmp/IPnett-Cloud-Root-CA.pem \

$GSK8CAPICMD -cert -list -db "$KDB" -stashed
