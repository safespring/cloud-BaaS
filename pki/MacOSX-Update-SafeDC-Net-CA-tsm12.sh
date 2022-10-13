#!/bin/sh
ROOTCA=SafeDC-Net-Root-CA-tsm12.pem
KDB="/Library/Application Support/tivoli/tsm/client/ba/bin/dsmcert.kdb"
GSK8CAPICMD=/Library/ibm/gsk8/bin/gsk8capicmd
RANDPW="$(openssl rand -base64 14)$RANDOM"

if [ ! -f "$KDB" ]; then
    $GSK8CAPICMD -keydb -create -db "$KDB" -pw $RANDPW -stash
else
    if [ -f $ROOTCA ]; then
	
	$GSK8CAPICMD -cert -add -db "$KDB" -format ascii -stashed \
		     -label "SafeDC Net Root CA" \
		     -file SafeDC-Net-Root-CA.pem
	
	$GSK8CAPICMD -cert -list -db "$KDB" -stashed
    else
	echo "SafeDC cert file $ROOTCA missing,"
	echo "please place it in current dir and re-run script"
	exit 1
    fi
fi
