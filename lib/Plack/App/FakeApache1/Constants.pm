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

        HTTP_BAD_REQUEST
        HTTP_UNAUTHORIZED
        HTTP_PAYMENT_REQUIRED
        HTTP_FORBIDDEN
        HTTP_NOT_FOUND
        HTTP_METHOD_NOT_ALLOWED
        HTTP_NOT_ACCEPTABLE
        HTTP_PROXY_AUTHENTICATION_REQUIRED
        HTTP_REQUEST_TIME_OUT
        HTTP_CONFLICT
        HTTP_GONE
        HTTP_LENGTH_REQUIRED
        HTTP_PRECONDITION_FAILED
        HTTP_REQUEST_ENTITY_TOO_LARGE
        HTTP_REQUEST_URI_TOO_LARGE
        HTTP_UNSUPPORTED_MEDIA_TYPE
        HTTP_RANGE_NOT_SATISFIABLE
        HTTP_EXPECTATION_FAILED
        HTTP_UNPROCESSABLE_ENTITY
        HTTP_LOCKED
        HTTP_FAILED_DEPENDENCY
    / ],
    groups => {
        default => [ qw/OK/ ],
        common  => [ qw/OK DONE DECLINED REDIRECT/ ],
        http    => [ qw/HTTP_MOVED_TEMPORARILY/ ],
        '3xx'   => [ qw/HTTP_MOVED_TEMPORARILY/ ],
        '4xx'   => [ qw/
                        HTTP_BAD_REQUEST
                        HTTP_UNAUTHORIZED
                        HTTP_PAYMENT_REQUIRED
                        HTTP_FORBIDDEN
                        HTTP_NOT_FOUND
                        HTTP_METHOD_NOT_ALLOWED
                        HTTP_NOT_ACCEPTABLE
                        HTTP_PROXY_AUTHENTICATION_REQUIRED
                        HTTP_REQUEST_TIME_OUT
                        HTTP_CONFLICT
                        HTTP_GONE
                        HTTP_LENGTH_REQUIRED
                        HTTP_PRECONDITION_FAILED
                        HTTP_REQUEST_ENTITY_TOO_LARGE
                        HTTP_REQUEST_URI_TOO_LARGE
                        HTTP_UNSUPPORTED_MEDIA_TYPE
                        HTTP_RANGE_NOT_SATISFIABLE
                        HTTP_EXPECTATION_FAILED
                        HTTP_UNPROCESSABLE_ENTITY
                        HTTP_LOCKED
                        HTTP_FAILED_DEPENDENCY
                     /],
    },
};

# useful values from httpd.h
# added on a 'needed to use' basis

# 3xx status codes
sub HTTP_MOVED_TEMPORARILY             { 302; }

# 4xx status codes
sub HTTP_BAD_REQUEST                   { 400; }
sub HTTP_UNAUTHORIZED                  { 401; }
sub HTTP_PAYMENT_REQUIRED              { 402; }
sub HTTP_FORBIDDEN                     { 403; }
sub HTTP_NOT_FOUND                     { 404; }
sub HTTP_METHOD_NOT_ALLOWED            { 405; }
sub HTTP_NOT_ACCEPTABLE                { 406; }
sub HTTP_PROXY_AUTHENTICATION_REQUIRED { 407; }
sub HTTP_REQUEST_TIME_OUT              { 408; }
sub HTTP_CONFLICT                      { 409; }
sub HTTP_GONE                          { 410; }
sub HTTP_LENGTH_REQUIRED               { 411; }
sub HTTP_PRECONDITION_FAILED           { 412; }
sub HTTP_REQUEST_ENTITY_TOO_LARGE      { 413; }
sub HTTP_REQUEST_URI_TOO_LARGE         { 414; }
sub HTTP_UNSUPPORTED_MEDIA_TYPE        { 415; }
sub HTTP_RANGE_NOT_SATISFIABLE         { 416; }
sub HTTP_EXPECTATION_FAILED            { 417; }
sub HTTP_UNPROCESSABLE_ENTITY          { 422; }
sub HTTP_LOCKED                        { 423; }
sub HTTP_FAILED_DEPENDENCY             { 424; }

sub DONE        { -2; }
sub DECLINED    { -1; }
sub OK          {  0; }
sub REDIRECT    { HTTP_MOVED_TEMPORARILY; }

1;
