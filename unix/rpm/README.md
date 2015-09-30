# IPnett RPM Repository

## RedHat Enterprise Linux 6


To enable the repos, you need to first install the repo file in
/etc/yum.repos.d as well as add the key file with the following command:

    rpmkeys --import RPM-GPG-KEY-ipnett

For your convinience, here is a cut-n-paste-friendly-command:

    curl -o /etc/pki/rpm-gpg/RPG-GPG-KEY-ipnett \
    https://raw.githubusercontent.com/IPnett/cloud-BaaS/master/unix/rpm/RPM-GPG-KEY-ipnett
      rpmkeys --import /etc/pki/rpm-gpg/RPG-GPG-KEY-ipnett/RPM-GPG-KEY-ipnett
    curl -o /etc/yum.repos.d/ipnett-el6.repo \
      https://raw.githubusercontent.com/IPnett/cloud-BaaS/master/unix/rpm/ipnett-el6.repo


## RedHat Enterprise Linux 7 / CentOS 7

To enable the repos, you need to first install the repo file in
/etc/yum.repos.d as well as add the key file with the following command:

    rpmkeys --import RPM-GPG-KEY-ipnett

For your convinience, here is a cut-n-paste-friendly-command:

    curl -o /etc/pki/rpm-gpg/RPG-GPG-KEY-ipnett \
    https://raw.githubusercontent.com/IPnett/cloud-BaaS/master/unix/rpm/RPM-GPG-KEY-ipnett
      rpmkeys --import /etc/pki/rpm-gpg/RPG-GPG-KEY-ipnett/RPM-GPG-KEY-ipnett
    curl -o /etc/yum.repos.d/ipnett-el7.repo \
      https://raw.githubusercontent.com/IPnett/cloud-BaaS/master/unix/rpm/ipnett-el7.repo
