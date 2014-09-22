# CLI for IPnett BaaS

## Configuration

**ipnett-baas** reads its default configuration, in YAML format, from the file
**ipnett-baas.yml** in the current working directory. An example configuration
file can be found below:

    endpoint: https://api.cloud.ipnett.se/tsm/
    access_key_id: xaivookaelei
    secret_access_key: shooJoo6eePiPhaesh1nengi
    verify_hostname: 1


## Dependencies

### Ubuntu

    apt-get install libjson-perl libyaml-perl libwww-perl 

### Redhat

    yum install perl-JSON perl-YAML perl-LWP-Protocol-https
