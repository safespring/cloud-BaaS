# CLI for IPnett BaaS

## Configuration

**ipnett-baas** reads its default configuration, in YAML format, from the file
**ipnett-baas.yml** in the current working directory. An example configuration
file can be found below:

    endpoint: https://api.cloud.ipnett.se/tsm/
    access_key_id: xaivookaelei
    secret_access_key: shooJoo6eePiPhaesh1nengi


## Dependencies

### Ubuntu

    apt-get install libjson-perl libyaml-perl libwww-perl 

### Redhat

    yum install perl-JSON perl-YAML perl-LWP-Protocol-https

## Usage Examples

    perl ipnett-baas.pl show domain example.com
    perl ipnett-baas.pl show domain example.com nodes
    perl ipnett-baas.pl create node server.example.com cc42 RHEL-7 dedup comp
    perl ipnett-baas.pl show domain example.com hostname server.example.com
    perl ipnett-baas.pl get node EEPH2JOME7
    perl ipnett-baas.pl get node EEPH2JOME7 schedules
    perl ipnett-baas.pl set node EEPH2JOME7 schedule FILE\_0400
    perl ipnett-baas.pl get node EEPH2JOME7 config
