# Depends on apr and apr-util:
# On Debian-based systems: apt-get install libapr1-dev libaprutil1-dev
# on RPM systems: yum install apr-devel apr-util-devel
CC=gcc
SYSTEM=DEBIAN
ifeq ($(SYSTEM),RH)
	APRINC=/usr/include/apr-1/
else
	APRINC=/usr/include/apr-1.0/
endif
CFLAGS=-O2 -lpthread -lapr-1 -laprutil-1 -Wall -I$(APRINC) -D$(SYSTEM)


parallel-stat:
	$(CC) $(CFLAGS) -o parallel-stat parallel-stat.c

parallel-stat-apr:
	$(CC) $(CFLAGS) -o parallel-stat-apr parallel-stat-apr.c

clean:
	rm -f parallel-stat-apr parallel-stat
