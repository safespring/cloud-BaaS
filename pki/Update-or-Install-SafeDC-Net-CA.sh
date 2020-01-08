#!/bin/sh

KDB=/opt/tivoli/tsm/client/ba/bin/dsmcert.kdb
GSK8CAPICMD=gsk8capicmd_64

$GSK8CAPICMD -cert -add -db "$KDB" -format ascii -stashed \
	-label "SafeDC Net Root CA" \
	-file SafeDC-Net-Root-CA.pem

$GSK8CAPICMD -cert -list -db "$KDB" -stashed
