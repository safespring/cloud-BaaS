OPENSSL_VERSION=	1.0.1m
STUNNEL_VERSION=	5.13

OPENSSL_TGZ=	openssl-${OPENSSL_VERSION}.tar.gz
STUNNEL_TGZ=	stunnel-${STUNNEL_VERSION}.tar.gz

ROOT_CA=	../../pki/IPnett-Cloud-Root-CA.pem
DIST_ROOT=	distroot/opt/stunnel-${STUNNEL_VERSION}
DIST_TGZ=	stunnel-static-${STUNNEL_VERSION}-openssl-${OPENSSL_VERSION}-$(shell arch).tar.gz

FETCH=		wget --no-check-certificate --no-clobber


all:

dist: ${DIST_TGZ}

${DIST_TGZ}: build
	install -d ${DIST_ROOT}
	install -d ${DIST_ROOT}/bin
	install -d ${DIST_ROOT}/etc
	install -m 555 stunnel-${STUNNEL_VERSION}/src/stunnel ${DIST_ROOT}/bin
	install -m 444 ${ROOT_CA} ${DIST_ROOT}/etc/stunnel-tsm.pem
	sed "s/%%VERSION%%/${STUNNEL_VERSION}/" stunnel.conf > stunnel.conf.tmp
	install -m 644 stunnel.conf.tmp ${DIST_ROOT}/etc/stunnel-tsm.conf
	(cd distroot; tar cvzf ../${DIST_TGZ} opt)

build: stunnel-${STUNNEL_VERSION}/src/stunnel

fetch: ${OPENSSL_TGZ} ${STUNNEL_TGZ}

fetch-gpg-keys:
	gpg --recv-key 0E604491
	gpg --recv-key D416E014

import-gpg-keys:
	gpg --import openssl.pgp
	gpg --import stunnel.pgp

export-gpg-keys:
	gpg --armor --export 0E604491 >openssl.pgp
	gpg --armor --export D416E014 >stunnel.pgp

${OPENSSL_TGZ}:
	${FETCH} https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
	${FETCH} https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz.asc
	gpg --verify openssl-*.tar.gz.asc || sha256sum -c SHA256.openssl

${STUNNEL_TGZ}:
	${FETCH} https://www.stunnel.org/downloads/archive/5.x/stunnel-${STUNNEL_VERSION}.tar.gz
	${FETCH} https://www.stunnel.org/downloads/archive/5.x/stunnel-${STUNNEL_VERSION}.tar.gz.asc
	gpg --verify stunnel-*.tar.gz.asc || sha256sum -c SHA256.stunnel

openssl-${OPENSSL_VERSION}: ${OPENSSL_TGZ}
	tar xzf ${OPENSSL_TGZ}

stunnel-${STUNNEL_VERSION}: ${STUNNEL_TGZ}
	tar xzf ${STUNNEL_TGZ}

openssl-${OPENSSL_VERSION}/lib/libssl.a: openssl-${OPENSSL_VERSION}
	(cd openssl-${OPENSSL_VERSION}; \
	./config no-shared no-dynamic -fPIC ; \
	sed -i 's/^SHARED_LDFLAGS/SHARED_LDFLAGS="-Wl,-z,relro -Wl,-z,now"' Makefile ; \
	make ${MAKEFLAGS} depend; \
	make ${MAKEFLAGS}; \
	mkdir lib && install -m 444 libcrypto.a libssl.a lib)

stunnel-${STUNNEL_VERSION}/src/stunnel: stunnel-${STUNNEL_VERSION} openssl-${OPENSSL_VERSION}/lib/libssl.a
	(cd stunnel-${STUNNEL_VERSION}; \
	./configure \
		--with-ssl=`pwd`/../openssl-${OPENSSL_VERSION} \
		--enable-static --disable-shared --disable-libwrap \
		--prefix /opt/stunnel-${STUNNEL_VERSION}; \
        find . -name Makefile \
          -exec sed -i 's/^CFLAGS =/CFLAGS = -fPIC/g' {} \; ;\
        make ${MAKEFLAGS})

clean-build:
	(cd openssl-${OPENSSL_VERSION}; make clean ; rm -rf lib)
	(cd stunnel-${STUNNEL_VERSION}; make clean)

clean:
	rm -fr openssl-*
	rm -fr stunnel-*
	rm -f *.tmp
	rm -f ${DIST_TGZ}
	rm -fr distroot
