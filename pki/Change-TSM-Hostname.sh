#!/bin/sh

DSM=/opt/tivoli/tsm/client/ba/bin/dsm.sys



if [ X"$(uname)" = X"Linux" ]; then

    cd $(dirname "$DSM")
    cat "$DSM" | sed -e 's/TCPSERVERADDRESS.*tsm1.cloud.ipnett.se/TCPSERVERADDRESS tsm1.backup.sto2.safedc.net/g' > ${DSM}.edited
    
    if [ X"$1" = X"auto" ]; then
	mv ${DSM}.edited ${DSM}
	systemctl restart dsmcad.service || /etc/init.d/dsmcad restart
    else
	echo "Does this look ok?"
	echo "If so, copy $DSM.edited over $DSM and restart dsmcad service"
	echo "or re-run script with: $0 auto"
	echo "------------------"
	cat "${DSM}.edited"
	echo "------------------"
    fi
else
    echo "Only meant to be run on Linux, uname says: $(uname)"
    exit 1
fi
