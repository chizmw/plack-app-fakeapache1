package Plack::App::FakeApache1::Constants;
use strict;
use warnings;

use Sub::Exporter -setup => {
    exports => [ qw/OK DONE DECLINED REDIRECT/ ],
    groups => {
        default => [ qw/OK/ ],
        common  => [ qw/OK DONE DECLINED REDIRECT/ ],
        http    => [ qw/HTTP_MOVED_TEMPORARILY/ ],
    },
};

# useful values from httpd.h
# added on a 'needed to use' basis
sub HTTP_MOVED_TEMPORARILY  { 302; }

sub DONE        { -2; }
sub DECLINED    { -1; }
sub OK          {  0; }
sub REDIRECT    { HTTP_MOVED_TEMPORARILY; }

1;
