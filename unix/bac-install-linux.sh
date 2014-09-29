#!/bin/sh
#
# Install TSM Backup Archive client and Cristie Bare machine recovery for TSM
#
################################################################################
# Howto: Place script along with the required RPM-files in the same directory 
#        Also the CA cert and change value for GSKFILE variable
# > gskssl64-8.0.14.28.linux.$ARCH.rpm
# > gskcrypt64-8.0.14.28.linux.$ARCH.rpm
# > TIVsm-API64.$ARCH.rpm
# > TIVsm-BA.$ARCH.rpm
# > tbmr-7.1-2.$ARCH.rpm
# > IPnett-Cloud-Root-CA.pem
################################################################################
#
##########################################
# Variable declaration                   #
##########################################
ARCH=`uname -p`
GSKSSL=gskssl64-8.0.14.28.linux.$ARCH.rpm
GSKCRYPT=gskcrypt64-8.0.14.28.linux.$ARCH.rpm
TIVAPI=TIVsm-API64.$ARCH.rpm
TIVBA=TIVsm-BA.$ARCH.rpm
BACDIR=/opt/tivoli/tsm/client/ba/bin
TBMR=tbmr-7.1-2.$ARCH.rpm
KPASS=mekmitasdigoat
GSKLABEL="IPnett BaaS Root CA"
GSKFILE=IPnett-Cloud-Root-CA.pem
DSMCERTFILE=/opt/tivoli/tsm/client/ba/bin/dsmcert.kdb
PASSWORD=$1

#############
# Functions #
#############
### Install reqired GSK Kit ###
function gskinstall() {
	rpm -Uvh $GSKSSL $GSKCRYPT
	if [ $? -eq 2 ];then
		echo "Error 99: Failed to install $GSKSSL"
	elif [ $? -eq 1 ];then
		echo "$GSKSSL && $GSKCRYPT installed already"
	elif [ $? -eq 0 ];then 
		echo "$GSKSSL succssfully installed"
	else
		echo "Error 90: Somethings wrong with $GSKSSL"
		exit 90
	fi

}
### Install required BA API ###
function baapiinstal() {
	rpm -Uvh $TIVAPI
	if [ $? -eq 2 ];then
		echo "Error 79: Failed to install $TIVAPI"
		exit 79
	elif [ $? -eq 1 ];then
		echo "$TIVAPI installed already"
	elif [ $? -eq 0 ];then 
		echo "$TIVAPI succssfully installed"
	else
		echo "Error 70: Somethings wrong with $TIVAPI"
		exit 70
	fi
}
### Install BA Client ###
function baclientinstall(){
	rpm -Uvh $TIVBA
	if [ $? -eq 2 ];then
		echo "Error 69: Failed to install $TIVBA"
		exit 69
	elif [ $? -eq 1 ];then
		echo "$TIVBA installed already"
	elif [ $? -eq 0 ];then 
		echo "$TIVBA succssfully installed"
	else
		echo "Error 60: Somethings wrong with $TIVBA"
		exit 60
	fi
}
### Install TBMR ###
function tbmrinstall() {
	rpm -i $TBMR	
	if [ $? -eq 0 ];then
		echo "$TBMR successfully installed"
	else
		echo "Error 9: $TBMR failed to install"
		exit 9
	fi
}

### Function for adding cert ### 
function addcert(){
	if [ -d $BACDIR ];then
		if [ -f $DSMCERTFILE ];then
			(cd $BACDIR && gsk8capicmd_64 -cert -add -db dsmcert.kdb -label "$GSKLABEL" -file $GSKFILE -format ascii -stashed)
		else
			(cd $BACDIR && gsk8capicmd_64 -keydb -create -populate -db dsmcert.kdb -pw $KPASS -stash)
			(cd $BACDIR && gsk8capicmd_64 -cert -add -db dsmcert.kdb -label "$GSKLABEL" -file $GSKFILE -format ascii -stashed)
		fi
	else
		echo "The TSM client directory don't exist, or is != default: $BACDIR"
		echo "  If not default dir, edit BACDIR variable and try again"
	fi
}
### Function for setting password ###
function setPass(){
	dsmc set password $1 $1 $1
}
##################
# Function calls #
##################
if [ $# -lt 2 ];then
	echo "You need to enter your provieded password as an argument for this script"
else
	gskinstall
	baapiinstal
	baclientinstall
	tbmrinstall
	addcert
	setPass $PASSWORD
fi
