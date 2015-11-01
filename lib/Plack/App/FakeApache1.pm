package Plack::App::FakeApache1;
# ABSTRACT: Plack::App::FakeApache1 needs a more meaningful abstract
use strict;
use warnings;

use Plack::Util;
use Plack::Util::Accessor qw( handler dir_config );
use parent qw( Plack::Component );
use attributes;

use Plack::App::FakeApache1::Request;
use Plack::App::FakeApache1::Constants qw(OK);

use Carp;
use HTTP::Status qw(:constants);
use Scalar::Util qw( blessed );

sub call {
    my ($self, $env) = @_;

    my $fake_req = Plack::App::FakeApache1::Request->new(
        env         => $env,
        dir_config  => $self->dir_config,
    );
    $fake_req->status( HTTP_OK );

    my $handler;
    if ( blessed $self->handler ) {
        $handler = sub { $self->handler->handler( $fake_req ) };
    } else {
        my $class   = $self->handler;
        my $method = eval { $class->can("handler") };

        if ( grep { $_ eq 'method' } attributes::get($method) ) {
            $handler = sub { $class->$method( $fake_req ) };
        } else {
            $handler = $method;
        }
    }

    my $result = $handler->( $fake_req );

    if ( $result != OK ) {
        $fake_req->status( $result );
    }

    return $fake_req->finalize;
}

sub prepare_app {
    my $self    = shift;
    my $handler = $self->handler;

    carp "handler not defined" unless defined $handler;

    $handler = Plack::Util::load_class( $handler ) unless blessed $handler;
    $self->handler( $handler );

    return;
}

1;
__END__
# vim: ts=8 sts=4 et sw=4 sr sta
