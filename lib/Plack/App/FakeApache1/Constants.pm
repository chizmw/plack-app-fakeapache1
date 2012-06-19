package Plack::App::FakeApache1::Constants;
use strict;
use warnings;

use Sub::Exporter -setup => {
    exports => [ qw/
        OK
        DONE
        DECLINED
        REDIRECT

        HTTP_MOVED_TEMPORARILY

        HTTP_METHOD_NOT_ALLOWED
    / ],
    groups => {
        default => [ qw/OK/ ],
        common  => [ qw/OK DONE DECLINED REDIRECT/ ],
        http    => [ qw/HTTP_MOVED_TEMPORARILY/ ],
        '3xx'   => [ qw/HTTP_MOVED_TEMPORARILY/ ],
        '4xx'   => [ qw/HTTP_METHOD_NOT_ALLOWED/ ],
    },
};

# useful values from httpd.h
# added on a 'needed to use' basis

# 3xx status codes
sub HTTP_MOVED_TEMPORARILY  { 302; }

# 4xx status codes
sub HTTP_METHOD_NOT_ALLOWED { 405; }

sub DONE        { -2; }
sub DECLINED    { -1; }
sub OK          {  0; }
sub REDIRECT    { HTTP_MOVED_TEMPORARILY; }

1;
