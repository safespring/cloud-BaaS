OPENSSL_VERSION=	1.0.1j
STUNNEL_VERSION=	5.07

OPENSSL_TGZ=	openssl-${OPENSSL_VERSION}.tar.gz
STUNNEL_TGZ=	stunnel-${STUNNEL_VERSION}.tar.gz

FETCH=		wget


all:

gpg-keys:
	gpg --recv-key 74C732D1
	gpg --recv-key 0E604491

${OPENSSL_TGZ}:
	${FETCH} https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
	${FETCH} https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz.asc
	gpg --verify openssl-*.tar.gz.asc

${STUNNEL_TGZ}:
	${FETCH} https://www.stunnel.org/downloads/stunnel-${STUNNEL_VERSION}.tar.gz
	${FETCH} https://www.stunnel.org/downloads/stunnel-${STUNNEL_VERSION}.tar.gz.asc
	gpg --verify stunnel-*.tar.gz.asc

openssl-${OPENSSL_VERSION}: ${OPENSSL_TGZ}
	tar xzf ${OPENSSL_TGZ}

stunnel-${STUNNEL_VERSION}: ${STUNNEL_TGZ}
	tar xzf ${STUNNEL_TGZ}

build-openssl: openssl-${OPENSSL_VERSION}
	(cd openssl-${OPENSSL_VERSION}; \
	./config no-shared && make; \
	mkdir lib && install -m 444 libcrypto.a libssl.a lib)

build-stunnel: stunnel-${STUNNEL_VERSION}
	(cd stunnel-${STUNNEL_VERSION}; \
	./configure \
		--with-ssl=`pwd`/../openssl-${OPENSSL_VERSION} \
		--enable-static --disable-shared \
		--prefix /opt/stunnel-${STUNNEL_VERSION}; \
	make)

clean:
	rm -fr openssl-*
	rm -fr stunnel-*
