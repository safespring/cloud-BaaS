#!/usr/bin/perl 
#
# Copyright (c) 2014 IPnett AB. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

use strict;
use warnings;

use MIME::Base64;
use LWP;
use LWP::UserAgent;
use LWP::Protocol::https;
use JSON;
use YAML;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;

my $config = "ipnett-baas.yml";

my $ua          = LWP::UserAgent->new();
my $endpoint    = undef;
my $auth        = undef;
my $impersonate = undef;
my $verbose     = 0;
my $fake        = 0;
my $raw         = 0;

sub rest_get ($) {
    my $resource = shift;

    my $url = sprintf("%s%s", $endpoint, $resource);
    my $req = HTTP::Request->new(GET => $url);
    $req->header('Authorization' => "Token $auth");
    $req->header('Impersonate' => $impersonate) if ($impersonate);

    return $req;
}

sub rest_delete ($) {
    my $resource = shift;

    my $url = sprintf("%s%s", $endpoint, $resource);
    my $req = HTTP::Request->new(DELETE => $url);
    $req->header('Authorization' => "Token $auth");
    $req->header('Impersonate' => $impersonate) if ($impersonate);

    return $req;
}

sub rest_post ($) {
    my $resource = shift;

    my $url = sprintf("%s%s", $endpoint, $resource);
    my $req = HTTP::Request->new(POST => $url);
    $req->header('Authorization' => "Token $auth");
    $req->header('Impersonate' => $impersonate) if ($impersonate);

    return $req;
}

sub rest_post_json ($$) {
    my $resource = shift;
    my $json     = shift;

    my $url = sprintf("%s%s", $endpoint, $resource);
    my $req = HTTP::Request->new(POST => $url);
    $req->header('Authorization' => "Token $auth");
    $req->header('Content-Type'  => "application/json");
    $req->header('Impersonate'   => $impersonate) if ($impersonate);
    $req->content($json);

    return $req;
}

sub rest_put_json ($$) {
    my $resource = shift;
    my $json     = shift;

    my $url = sprintf("%s%s", $endpoint, $resource);
    my $req = HTTP::Request->new(PUT => $url);
    $req->header('Authorization' => "Token $auth");
    $req->header('Content-Type'  => "application/json");
    $req->header('Impersonate'   => $impersonate) if ($impersonate);
    $req->content($json);

    return $req;
}

sub main() {
    my $help    = 0;
    my $man     = 0;
    my $request = undef;

    GetOptions(
        "config=s"      => \$config,
        "impersonate=s" => \$impersonate,
        'help|?'        => \$help,
        'man'           => \$man,
        'verbose+'      => \$verbose,
        'fake'          => \$fake,
        'raw'           => \$raw,
    ) or pod2usage(2);

    pod2usage(1) if $help;
    pod2usage(-exitval => 0, -verbose => 2) if $man;

    my $verb = shift @ARGV;
    my $subj = shift @ARGV;

    my $filename;

    unless ($verb and $subj) {
        pod2usage(-1);
    }

    die "$config not found" unless (-f $config);
    my ($hashref, $arrayref, $string) = YAML::LoadFile($config);

    die "no API endpoint set"          unless ($hashref->{endpoint});
    die "no API access_key_id set"     unless ($hashref->{access_key_id});
    die "no API secret_access_key set" unless ($hashref->{secret_access_key});

    if (defined($hashref->{verify_hostname})) {
        $ua->ssl_opts('verify_hostname' => $hashref->{verify_hostname});
    }

    # enforce TLS v1.2
    $ua->ssl_opts(SSL_version => 'TLSv12');

    $endpoint = $hashref->{endpoint};
    $auth =
      encode_base64(
        join(':', $hashref->{access_key_id}, $hashref->{secret_access_key}),
        "");

    if ($verb eq "get" or $verb eq "show") {

        if ($subj eq "domains") {
            $request = rest_get("domains");
        } elsif ($subj eq "users") {
            $request = rest_get("users");
        } elsif ($subj eq "keys") {
            $request = rest_get("keys");
        } elsif ($subj eq "nodes") {
            $request = rest_get("nodes");
        } elsif ($subj eq "servers") {
            $request = rest_get("servers");
        } elsif ($subj eq "platforms") {
            $request = rest_get("platforms");
        } elsif ($subj eq "applications") {
            $request = rest_get("applications");
        } elsif ($subj eq "domain") {
            my $domain = shift @ARGV;
            my $subreq = shift @ARGV;
            my $subarg = shift @ARGV;

            pod2usage(-message => "Missing domain name") unless ($domain);

            if ($subreq and $subreq eq "nodes") {
                $request = rest_get("domains/$domain/nodes");
            } elsif ($subreq and $subreq eq "users") {
                $request = rest_get("domains/$domain/users");
            } elsif ($subreq and $subreq eq "admins") {
                $request = rest_get("domains/$domain/admins");
            } elsif ($subreq and $subreq eq "hostname") {
                $request = rest_get("domains/$domain/nodes?hostname=$subarg");
            } else {
                $request = rest_get("domains/$domain");
            }
        } elsif ($subj eq "user") {
            my $user   = shift @ARGV;
            my $subreq = shift @ARGV;

            pod2usage(-message => "Missing user name") unless ($user);

            if ($subreq and $subreq eq "nodes") {
                $request = rest_get("users/$user/nodes");
            } else {
                $request = rest_get("users/$user");
            }
        } elsif ($subj eq "key") {
            my $key = shift @ARGV;
            pod2usage(-message => "Missing key id") unless ($key);
            $request = rest_get("keys/$key");
        } elsif ($subj eq "node") {
            my $nodename = shift @ARGV;
            my $subreq   = shift @ARGV;

            pod2usage(-message => "Missing node name") unless ($nodename);

            if ($subreq and $subreq eq "schedules") {
                $request = rest_get("nodes/$nodename/schedules");
            } elsif ($subreq and $subreq eq "policies") {
                $request = rest_get("nodes/$nodename/policies");
            } elsif ($subreq and $subreq eq "config") {
                $request  = rest_get("nodes/$nodename/config");
                $filename = "dsm-$nodename.zip";
            } else {
                $request = rest_get("nodes/$nodename");
            }
        } else {
            pod2usage(-1);
        }

    } elsif ($verb eq "create") {

        if ($subj eq "key") {

            my $description = shift @ARGV;
            $request =
              rest_post_json("keys",
                encode_json({ description => $description }));

        } elsif ($subj eq "node") {

            my $hostname    = shift @ARGV;
            my $cost_center = shift @ARGV;

            pod2usage(-message => "Missing host name")   unless ($hostname);
            pod2usage(-message => "Missing cost center") unless ($cost_center);

            my $encryption    = 0;
            my $deduplication = 0;
            my $compression   = 0;

            foreach my $opt (@ARGV) {
                $encryption    = 1 if ($opt =~ /^encr/);
                $encryption    = 0 if ($opt =~ /^noencr/);
                $deduplication = 1 if ($opt =~ /^dedup/);
                $deduplication = 0 if ($opt =~ /^nodedup/);
                $compression   = 1 if ($opt =~ /^comp/);
                $compression   = 0 if ($opt =~ /^nocomp/);
            }

            $request = rest_post_json(
                "nodes",
                encode_json(
                    {
                        hostname      => $hostname,
                        cost_center   => $cost_center,
                        encryption    => ($encryption ? 1 : 0),
                        deduplication => ($deduplication ? 1 : 0),
                        compression   => ($compression ? 1 : 0),
                    }
                )
            );

        } else {
            pod2usage(-1);
        }

    } elsif ($verb eq "set") {

        if ($subj eq "node") {

            my $nodename = shift @ARGV;
            my $subreq   = shift @ARGV;
            my $subarg   = shift @ARGV;

            pod2usage(-message => "Missing node name") unless ($nodename);

            if ($subreq and $subreq eq "policy") {
                pod2usage(-message => "Missing policy name") unless ($subarg);

                $request =
                  rest_put_json("nodes/$nodename",
                    encode_json({ policy => $subarg }));
            } elsif ($subreq
                and ($subreq eq "schedule" or $subreq eq "schedules"))
            {
                pod2usage(-message => "Missing schedule name") unless ($subarg);

                if ($subarg eq "NULL") {
                    $request =
                      rest_put_json("nodes/$nodename",
                        encode_json({ schedules => [] }));
                } else {
                    my @schedules = split(/,/, $subarg);
                    $request =
                      rest_put_json("nodes/$nodename",
                        encode_json({ schedules => \@schedules }));
                }
            } elsif ($subreq
                and ($subreq eq "platform"))
            {
                pod2usage(-message => "Missing platform name") unless ($subarg);

                $request =
                  rest_put_json("nodes/$nodename",
                    encode_json({ platform => $subarg }));
            } else {
                pod2usage(-1);
            }

        } else {
            pod2usage(-1);
        }
    } elsif ($verb eq "rekey") {

        if ($subj eq "node") {
            my $nodename = shift @ARGV;
            pod2usage(-message => "Missing node name") unless ($nodename);
            $request = rest_post("nodes/$nodename/rekey");
        } else {
            pod2usage(-1);
        }

    } elsif ($verb eq "lock") {

        if ($subj eq "node") {
            my $nodename = shift @ARGV;
            pod2usage(-message => "Missing node name") unless ($nodename);
            $request =
              rest_put_json("nodes/$nodename",
                encode_json({ locked_by_user => 1 }));
        } else {
            pod2usage(-1);
        }

    } elsif ($verb eq "unlock") {

        if ($subj eq "node") {
            my $nodename = shift @ARGV;
            pod2usage(-message => "Missing node name") unless ($nodename);
            $request =
              rest_put_json("nodes/$nodename",
                encode_json({ locked_by_user => 0 }));
        } else {
            pod2usage(-1);
        }

    } elsif ($verb eq "delete") {

        if ($subj eq "domain") {
            my $domain = shift @ARGV;
            pod2usage(-message => "Missing domain name") unless ($domain);
            $request = rest_delete("domains/$domain");
        } elsif ($subj eq "user") {
            my $user = shift @ARGV;
            pod2usage(-message => "Missing user name") unless ($user);
            $request = rest_delete("users/$user");
        } elsif ($subj eq "key") {
            my $key = shift @ARGV;
            pod2usage(-message => "Missing key id") unless ($key);
            $request = rest_delete("keys/$key");
        } elsif ($subj eq "node") {
            my $nodename = shift @ARGV;
            pod2usage(-message => "Missing node name") unless ($nodename);
            $request = rest_delete("nodes/$nodename");
        } else {
            pod2usage(-1);
        }

    } else {

        pod2usage(-1);

    }

    print STDERR $request->as_string if ($verbose);

    exit(-1) if ($fake);

    my $response = $ua->request($request);

    die "No response from server" unless ($response);

    if ($verbose) {
        print STDERR $response->status_line, "\n";
        print STDERR $response->headers->as_string, "\n" if ($verbose > 1);
    } else {
        my $r = $response->code;
        if ($response->is_success) {
            print STDERR "OK\n";
        } elsif ($r == 403) {
            print STDERR
              "FORBIDDEN (you are probably using the wrong command)\n";
        } elsif ($r = 404) {
            print STDERR "NOT FOUND (typo?)\n";
        } elsif ($r >= 500) {
            print STDERR "SERVER ERROR $r\n";
        } else {
            print STDERR "ERROR $r\n";
        }
    }

    if ($response->header("Content-Type") =~ /^application\/json/) {
        if ($raw) {
            print $response->content, "\n";
        } else {
            my $perl_scalar = decode_json($response->content);
            print to_json($perl_scalar, { utf8 => 1, pretty => 1 });
        }
    } elsif ($response->header("Content-Type") =~ /^text\//) {
        print $response->content, "\n";
    } elsif ($response->header("Content-Type") eq "application/zip") {
        if ($filename) {
            my $fh;
            if (-f $filename) {
                print STDERR
                  "$filename already exists, please remove it first.\n";
                exit(1);
            }
            open($fh, ">", $filename);
            unless ($fh) {
                print STDERR "Unable to create file: $filename\n";
                exit(1);
            }
            print $fh $response->content;
            close($fh);
        }
    } else {
        print STDERR "Unknown Content-Type\n";
    }

    if ($response->is_success) {
        exit(0);
    } else {
        exit($response->code);
    }
}

main;

__END__

=head1 NAME

ipnett-baas - CLI for IPnett BaaS

=head1 SYNOPSIS

ipnett-baas [options] [command]

 Options:
   --help              brief help message
   --man               show full man page
   --config=file       use non-default configuration file (YAML)
   --verbose           verbose output (may be used multiple times)
   --raw               RAW JSON output
   --fake              do not actually send request
   --impersonate=user  try to impersonate user

 Commands:

    get platforms
    get applications
    get domain [domain]
    get domain [domain] (nodes|users|admins)
    get domain [domain] hostname [hostname]
    get user [user]
    get user [user] nodes
    get key [key]
    get node [node]
    get node [node] (schedules|policies|config)

    create key [description]
    create node [hostname] [costcenter] (encr|dedup) (comp)
    rekey node [nodename]
    lock node [nodename]
    unlock node [nodename]
    set node [node] policy [policy]
    set node [node] schedule [schedule]
    set node [node] platform [platform]

    delete domain [domain]
    delete user [username]
    delete key [key]
    delete node [nodename]

    get domains  (global admin only)
    get users    (global admin only)
    get keys     (global admin only)
    get nodes    (global admin only)
    get servers  (global admin only)

=head1 DESCRIPTION

B<ipnett-baas> is a simple CLI for the IPnett BaaS REST API. Default
configuration file is ipnett-baas.yaml in the current working directory.

=head1 CONFIGURATION

B<ipnett-baas> reads its default configuration, in YAML format, from the file
B<ipnett-baas.yml> in the current working directory. An example configuration
file can be found below:

    endpoint: https://api.cloud.ipnett.se/tsm/
    access_key_id: xaivookaelei
    secret_access_key: shooJoo6eePiPhaesh1nengi
    verify_hostname: 1

=cut
