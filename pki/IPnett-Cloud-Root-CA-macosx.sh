#!/bin/sh

PASSWORD=$(mktemp -d /tmp/temp-one-time-idXXXXXXXXXXXXX)
rmdir $PASSWORD

KDB="/Library/Application Support/tivoli/tsm/client/ba/bin/dsmcert.kdb"
GSK8CAPICMD=/Library/ibm/gsk8/bin/gsk8capicmd

rm -f "/Library/Application Support/tivoli/tsm/client/ba/bin/dsmcert.*"

$GSK8CAPICMD -keydb -create -db "$KDB" -pw "$PASSWORD" -stash

$GSK8CAPICMD -cert -add -db "$KDB" -format ascii -stashed \
	-label "IPnett BaaS Root CA" \
	-file ./IPnett-Cloud-Root-CA.pem

$GSK8CAPICMD -cert -list -db "$KDB" -stashed
