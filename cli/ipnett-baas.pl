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
use LWP::UserAgent;
use LWP::Protocol::https;
use JSON;
use YAML;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;

my $config = "ipnett-baas.yml";
my $pretty = 0;

my $ua          = LWP::UserAgent->new();
my $endpoint    = undef;
my $auth        = undef;
my $impersonate = undef;

sub rest_get ($) {
    my $resource = shift;

    my $url = sprintf("%s%s", $endpoint, $resource);
    my $req = HTTP::Request->new(GET => $url);
    $req->header('Authorization' => "Token $auth");
    $req->header('Impersonate' => $impersonate) if ($impersonate);

    return $ua->request($req);
}

sub rest_delete ($) {
    my $resource = shift;

    my $url = sprintf("%s%s", $endpoint, $resource);
    my $req = HTTP::Request->new(DELETE => $url);
    $req->header('Authorization' => "Token $auth");
    $req->header('Impersonate' => $impersonate) if ($impersonate);

    return $ua->request($req);
}

sub rest_post ($) {
    my $resource = shift;

    my $url = sprintf("%s%s", $endpoint, $resource);
    my $req = HTTP::Request->new(POST => $url);
    $req->header('Authorization' => "Token $auth");
    $req->header('Impersonate' => $impersonate) if ($impersonate);

    return $ua->request($req);
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

    return $ua->request($req);
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
    return $ua->request($req);
}

sub output_content($) {
    my $content = shift;

    return unless ($content);

    if ($pretty) {
        my $perl_scalar = decode_json($content);
        print to_json($perl_scalar, { utf8 => 1, pretty => 1 });
    } else {
        print $content, "\n";
    }
}

sub main() {
    my $help     = 0;
    my $man      = 0;
    my $response = undef;

    GetOptions(
        "pretty"        => \$pretty,
        "config=s"      => \$config,
        "impersonate=s" => \$impersonate,
        'help|?'        => \$help,
        'man'           => \$man,
    ) or pod2usage(2);

    pod2usage(1) if $help;
    pod2usage(-exitval => 0, -verbose => 2) if $man;

    my $verb = shift @ARGV;
    my $subj = shift @ARGV;

    unless ($verb and $subj) {
        pod2usage(-1);
    }

    die "$config not found" unless (-f $config);
    my ($hashref, $arrayref, $string) = YAML::LoadFile($config);

    die "no API endpoint set" unless ($hashref->{endpoint});
    die "no API username set" unless ($hashref->{username});
    die "no API password set" unless ($hashref->{password});

    if (defined($hashref->{verify_hostname})) {
        $ua->ssl_opts('verify_hostname' => $hashref->{verify_hostname});
    }

    $endpoint = $hashref->{endpoint};
    $auth =
      encode_base64(join(':', $hashref->{username}, $hashref->{password}), "");

    if ($verb eq "get" or $verb eq "show") {

        if ($subj eq "domains") {
            $response = rest_get("domains");
        } elsif ($subj eq "users") {
            $response = rest_get("users");
        } elsif ($subj eq "keys") {
            $response = rest_get("keys");
        } elsif ($subj eq "nodes") {
            $response = rest_get("nodes");
        } elsif ($subj eq "servers") {
            $response = rest_get("servers");
        } elsif ($subj eq "platforms") {
            $response = rest_get("platforms");
        } elsif ($subj eq "applications") {
            $response = rest_get("applications");
        } elsif ($subj eq "domain") {
            my $domain = shift @ARGV;
            $response = rest_get("domains/$domain");
        } elsif ($subj eq "user") {
            my $user = shift @ARGV;
            $response = rest_get("users/$user");
        } elsif ($subj eq "key") {
            my $key = shift @ARGV;
            $response = rest_get("keys/$key");
        } elsif ($subj eq "node") {
            my $nodename = shift @ARGV;
            my $subreq   = shift @ARGV;

            if ($subreq and $subreq eq "schedules") {
                $response = rest_get("nodes/$nodename/schedules");
            } elsif ($subreq and $subreq eq "policies") {
                $response = rest_get("nodes/$nodename/policies");
            } else {
                $response = rest_get("nodes/$nodename");
            }
        } else {
            pod2usage(-1);
        }

    } elsif ($verb eq "create") {

        if ($subj eq "key") {

            my $description = shift @ARGV;
            $response =
              rest_post_json("keys",
                encode_json({ description => $description }));

        } elsif ($subj eq "node") {

            my $hostname    = shift @ARGV;
            my $cost_center = shift @ARGV;

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

            $response = rest_post_json(
                "nodes",
                encode_json(
                    {
                        hostname      => $hostname,
                        cost_center   => $cost_center,
                        encryption    => ($encryption ? 1 : 0),
                        deduplication => ($deduplication ? 1 : 0),
                        ##compression   => ($compression ? 1 : 0),
                    }
                )
            );

        } else {
            pod2usage(-1);
        }

    } elsif ($verb eq "rekey") {

        if ($subj eq "node") {
            my $nodename = shift @ARGV;
            $response = rest_post("nodes/$nodename/rekey");
        } else {
            pod2usage(-1);
        }

    } elsif ($verb eq "lock") {

        if ($subj eq "node") {
            my $nodename = shift @ARGV;
            $response =
              rest_put_json("nodes/$nodename",
                encode_json({ locked_by_user => 1 }));
        } else {
            pod2usage(-1);
        }

    } elsif ($verb eq "unlock") {

        if ($subj eq "node") {
            my $nodename = shift @ARGV;
            $response =
              rest_put_json("nodes/$nodename",
                encode_json({ locked_by_user => 0 }));
        } else {
            pod2usage(-1);
        }

    } elsif ($verb eq "delete") {

        if ($subj eq "domain") {
            my $domain = shift @ARGV;
            $response = rest_delete("domains/$domain");
        } elsif ($subj eq "user") {
            my $user = shift @ARGV;
            $response = rest_delete("users/$user");
        } elsif ($subj eq "key") {
            my $key = shift @ARGV;
            $response = rest_delete("keys/$key");
        } elsif ($subj eq "node") {
            my $nodename = shift @ARGV;
            $response = rest_delete("nodes/$nodename");
        } else {
            pod2usage(-1);
        }

    } else {

        pod2usage(-1);

    }

    die "No response" unless ($response);
    print STDERR $response->status_line, "\n";
    output_content($response->content);

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
   --pretty            pretty print JSON output
   --config=file       use non-default configuration file (YAML)
   --impersonate=user  try to impersonate user

 Commands:

    get domains
    get users
    get keys
    get nodes
    get servers
    get platforms
    get applications
    get domain [domain]
    get user [user]
    get key [key]
    get node [node]
    get node [node] schedules
    get node [node] policies

    create key [description]
    create node [hostname] [costcenter] [encr] [dedup] [comp]
    rekey node [nodename]
    lock node [nodename]
    unlock node [nodename]

    delete domain [domain]
    delete user [username]
    delete key [key]
    delete node [nodename]

=head1 DESCRIPTION

B<ipnett-baas> is a simple CLI for the IPnett BaaS REST API. Default
configuration file is ipnett-baas.yaml in the current working directory.

=cut
