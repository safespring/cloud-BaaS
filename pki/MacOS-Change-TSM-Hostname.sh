#!/bin/sh

DSM="/Library/Preferences/Tivoli Storage Manager/dsm.sys"

if [ X"$(uname)" = X"Darwin" ]; then

    cd "/Library/Preferences/Tivoli Storage Manager/"
    cat "$DSM" | sed -e 's/TCPSERVERADDRESS.*tsm1.cloud.ipnett.se/TCPSERVERADDRESS tsm1.backup.sto2.safedc.net/g' > ${DSM}.edited
    
    if [ X"$1" = X"auto" ]; then
	mv "${DSM}.edited" "${DSM}"
	launchctl unload /Library/LaunchDaemons/com.ibm.tivoli.dsmcad.plist
	echo "Restarting dsmcad"
	sleep 5
	launchctl load /Library/LaunchDaemons/com.ibm.tivoli.dsmcad.plist 
    else
	echo "Does this look ok?"
	echo "If so, copy $DSM.edited over $DSM and restart dsmcad service"
	echo "or re-run script with: $0 auto"
	echo "------------------"
	cat "${DSM}.edited"
	echo "------------------"
    fi
else
    echo "Only meant to be run on MacOS (Darwin), uname says: $(uname)"
    exit 1
fi
