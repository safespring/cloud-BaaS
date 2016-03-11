OPENSSL_VERSION=	1.0.2g
STUNNEL_VERSION=	5.31
# Release update process:
# 1. Update OPENSSL_VERSION or STUNNEL_VERSION, or both
# 2. Run "make validate_update_digests"
# 3. If validated, commit new digests as well as Makefile

OPENSSL_TGZ=		openssl-${OPENSSL_VERSION}.tar.gz
STUNNEL_TGZ=		stunnel-${STUNNEL_VERSION}.tar.gz

PGP_KEYIDS=		0E604491 D416E014
# OpenSSL signing key: 0E604491
# Stunnel signing key: D416E014

ROOT_CA=	../../pki/IPnett-Cloud-Root-CA.pem
DIST_ROOT=	distroot/opt/stunnel-${STUNNEL_VERSION}
DIST_TGZ=	stunnel-static-${STUNNEL_VERSION}-openssl-${OPENSSL_VERSION}-$(shell arch).tar.gz

FETCH=		wget --no-check-certificate --no-clobber

GNUPGHOME=	gnupg
GPG_PUBRING=	./stunnel-pubring.gpg
GPG_COMMAND=	GNUPGHOME=$(GNUPGHOME) gpg --no-options --no-default-keyring --keyserver=hkp://keys.gnupg.net --keyring $(GPG_PUBRING)

DEPS_EL=	gcc gnupg

all:

depends: depends-el

depends-el:
	# IF WE ARE EL
	sudo yum makecache
	sudo yum install -y $(DEPS_EL)

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

build: depends gpg-keys stunnel-${STUNNEL_VERSION}/src/stunnel

fetch: ${OPENSSL_TGZ} ${STUNNEL_TGZ}

$(GNUPGHOME):
	install -m 0700 -d $@

gpg-keys: $(PGP_KEYIDS)

$(PGP_KEYIDS): $(GNUPGHOME)
	$(GPG_COMMAND) --fingerprint $@ 2>/dev/null || (\
		$(GPG_COMMAND) --recv-key $@ || \
		$(GPG_COMMAND) --import $@.pgp.asc ) && \
	$(GPG_COMMAND) --armor --export $@ > $@.pgp.asc

# Update SHA-files if they do not match and GPG is verified
# Contains temporary fix, as openssl sha256-sums are incorrectly formatted
validate_update_digests: ${OPENSSL_TGZ} ${STUNNEL_TGZ}
	$(GPG_COMMAND) --verify openssl-*.tar.gz.asc && \
		sha256sum -c SHA256.openssl || (\
		(${FETCH} https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz.sha256 || \
			${FETCH} http://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz.sha256 ) && \
		mv openssl-${OPENSSL_VERSION}.tar.gz.sha256 SHA256.openssl && \
		sed -i 's/$$/ openssl-${OPENSSL_VERSION}.tar.gz/g' SHA256.openssl ) \
	&& \
	$(GPG_COMMAND) --verify stunnel-*.tar.gz.asc && \
		sha256sum -c SHA256.stunnel || ( \
		${FETCH} https://www.stunnel.org/downloads/archive/5.x/stunnel-${STUNNEL_VERSION}.tar.gz.sha256 && \
		mv stunnel-${STUNNEL_VERSION}.tar.gz.sha256 SHA256.stunnel \
		)

# Prefer https, fallback if https fails.

${OPENSSL_TGZ}: gpg-keys
	${FETCH} https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz || \
		${FETCH} http://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
	${FETCH} https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz.asc || \
		${FETCH} http://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz.asc
	$(GPG_COMMAND) --verify openssl-*.tar.gz.asc || sha256sum -c SHA256.openssl

${STUNNEL_TGZ}: gpg-keys
	${FETCH} https://www.stunnel.org/downloads/archive/5.x/stunnel-${STUNNEL_VERSION}.tar.gz
	${FETCH} https://www.stunnel.org/downloads/archive/5.x/stunnel-${STUNNEL_VERSION}.tar.gz.asc
	$(GPG_COMMAND) --verify stunnel-*.tar.gz.asc || sha256sum -c SHA256.stunnel

openssl-${OPENSSL_VERSION}: ${OPENSSL_TGZ}
	tar xzf ${OPENSSL_TGZ}

stunnel-${STUNNEL_VERSION}: ${STUNNEL_TGZ}
	tar xzf ${STUNNEL_TGZ}

openssl-${OPENSSL_VERSION}/lib/libssl.a: openssl-${OPENSSL_VERSION}
	(cd openssl-${OPENSSL_VERSION}; \
	./config no-shared no-dynamic -fPIC ; \
	sed -i 's/^SHARED_LDFLAGS/SHARED_LDFLAGS="-Wl,-z,relro -Wl,-z,now"/g' Makefile ; \
	make ${MAKEFLAGS} depend && \
	make ${MAKEFLAGS} && \
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
	rm -rf openssl-*
	rm -rf stunnel-*
	rm -f *.tmp
	rm -f *.pgp.asc
	rm -f ${DIST_TGZ}
	rm -rf distroot gnupg
