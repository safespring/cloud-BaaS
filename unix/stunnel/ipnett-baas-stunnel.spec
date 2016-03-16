Name:           ipnett-baas-stunnel
Version:        0.3
Release:        1
Summary:        TLS 1.2 wrapper for older Linux platforms.
BuildArch:      %{_arch}

Group:          Applications/Internet
License:        BSD

Vendor:         IPnett AB
Packager:       Cloud Services, IPnett AB
URL:            https://github.com/IPnett/cloud-BaaS/wiki/Installation-RHEL

Requires:	bash
BuildRequires:	gpg
BuildRequires:	gcc
BuildRequires:	python
BuildRequires:	python-dateutil


%description
Static build of up-to-date Stunnel and OpenSSL in order to backport support
of TSM with TLS1.2 to older platforms that are out of modern TSM support.

%build
make stunnel-dist
# python mkchangelog.py --rpm > changes.rpm

%install
tar zxf stunnel-static*.tar.gz -C %{buildroot}
mkdir -p %{buildroot}/etc/init.d
cp dsmcad.redhat %{buildroot}/etc/init.d/dsmcad.rpmnew
cp ipnett-baas-stunnel-setup %{buildroot}/opt/stunnel/bin

%pre

# TODO: generate actual stunnel-tsm.conf from tsm config file:
#       do this using a setup-script in /opt/stunnel/bin

%post

if [ "$1" = "1" ]; then
	# Fresh install of package case
	if [ ! -f /etc/init.d/dsmcad ]; then
		mv /etc/init.d/dsmcad.rpmnew /etc/init.d/dsmcad
		/sbin/chkconfig dsmcad on
	fi
elif [ "$1" = "2" ]; then
	# Upgrade of same package case
	mv /etc/init.d/dsmcad.rpmnew /etc/init.d/dsmcad
fi

%preun

# Uninstall case
if [ "$1" = "0" ]; then
    /sbin/service dsmcad stop
    /sbin/chkconfig dsmcad off
fi

%files
%dir %attr(0755,root,root) /opt/stunnel
%dir %attr(0755,root,root) /opt/stunnel/bin
%dir %attr(0755,root,root) /opt/stunnel/etc
%attr(0755,root,root) /etc/init.d/dsmcad.rpmnew
%attr(0644,root,root) /opt/stunnel/bin/stunnel
%attr(0644,root,root) /opt/stunnel/bin/ipnett-baas-stunnel-setup
%attr(0644,root,root) /opt/stunnel/etc/stunnel-tsm.pem
%attr(0644,root,root) /opt/stunnel/etc/stunnel-tsm.conf.template

%changelog
%(python mkchangelog.py --rpm)

