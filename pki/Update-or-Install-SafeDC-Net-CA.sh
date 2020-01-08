#!/bin/sh

KDB=/opt/tivoli/tsm/client/ba/bin/dsmcert.kdb
GSK8CAPICMD=gsk8capicmd_64

if [ -f SafeDC-Net-Root-CA.pem ]; then

    $GSK8CAPICMD -cert -add -db "$KDB" -format ascii -stashed \
		 -label "SafeDC Net Root CA" \
		 -file SafeDC-Net-Root-CA.pem

    $GSK8CAPICMD -cert -list -db "$KDB" -stashed
else
    echo "SafeDC cert file SafeDC-Net-Root-CA.pem missing,"
    echo "please place it in current dir and re-run script"
    exit 1
fi
