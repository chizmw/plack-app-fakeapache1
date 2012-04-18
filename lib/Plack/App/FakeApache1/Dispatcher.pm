package Plack::App::FakeApache1::Dispatcher;
use strict;
use warnings;
use Moose;

use feature ':5.10';

use Apache::ConfigParser;
use Data::Printer;
use TryCatch;
use HTTP::Status qw(:constants :is status_message);
use lib $ENV{XTDC_BASE_DIR} . qw( /lib );

has config_file_name => (
    is          => 'rw',
    isa         => 'Str',
);

has parsed_apache_config => (
    is      => 'ro',
    isa     => 'Apache::ConfigParser',
    lazy    => 1,
    builder => '_build_parsed_apache_config',
);

has dispatches => (
    is      => 'ro',
    isa     => 'ArrayRef',
    lazy    => 1,
    builder => '_build_dispatches',
);

has debug => (
    is          => 'rw',
    isa         => 'Bool',
    default     => 0,
);

no Moose;

sub _build_parsed_apache_config {
    my $self = shift;
    my $config = Apache::ConfigParser->new;
    my $rc = $config->parse_file($self->config_file_name);
    if (not $rc) {
        die $config->errstr;
        exit;
    }

    return $config;
}


=for explanation

We try to mimic the behaviour we're seeing in the apache/mod_perl world with
our matching&dispatching; our current best guess is to 'use the "best match"',
which we're saying is 'the one with the most path-parts (i.e. most /
characters)

Looking at:
http://ertw.com/blog/2007/08/23/apache-and-overlapping-location-directives/

So the general plan of action iis to process each match in order, and store
any new settings, potentially overriding existing ones.
This appears to be how apache does it, and hasn't broken in any obvious ways
yet.

=cut
sub dispatch_for {
    my $self    = shift;
    my $plack   = shift;
    my $uri     = $plack->{env}{PATH_INFO};
    say $uri
        if $self->debug;
    my %location_config = %{ $self->_prepare_location_config_for( $uri ) };

    # if we have something in our config we can try to dispatch there
    if (keys %location_config) {
        my $action_blob = \%location_config;

        say "<$uri> matches " . join(',', @{ $location_config{location_regexps} })
            if $self->debug;

        # fake the order hadnlers are dealt with in mod_perl
        my @handler_order =
            qw(perlinithandler perlhandler perlloghandler perlcleanuphandler);

        foreach my $handler_type (@handler_order) {
            next
                unless exists($location_config{$handler_type});

            my @handlers = @{ $location_config{$handler_type} };
            say "$handler_type: @handlers"
                if $self->debug;
            foreach my $module (@handlers) {
                $self->_require_handler_module($module);
                $self->_call_handler($plack, $module);
                # no point continuing if we've been asked to redirect
                return
                    if is_redirect($plack->{response}{status});
            }
        }
        return;
    }

    # essentially a 404, no?
    say "Failed to match <$uri> against anything";
    $plack->{response}->status(HTTP_NOT_FOUND);
}

sub _prepare_location_config_for {
    my $self = shift;
    my $uri  = shift;

    my %location_config = ();
    my $dispatches = $self->dispatches;

    foreach my $dispatch_blob (@$dispatches) {
        if ($uri =~ m{$dispatch_blob->{location_re}}) {
            # merge config, overwriting any existing settings with later
            # matches
            # NOTE: we don't deal with +My::Module settings here at all
            %location_config = (
                %location_config,
                %{ $dispatch_blob }
            );
            # keep the location(s) and location_re(s) we matched; just in case
            # we need it to debug later
            push @{ $location_config{locations} },          $dispatch_blob->{location};
            push @{ $location_config{location_regexps} },   $dispatch_blob->{location_re};
        }
    }
    # throwaway 'location' and 'location_re'; these only tell us the last one
    # we matched ans we can see that from 'locations' and 'location_regexps'
    foreach my $k (qw/location location_re/) {
        delete $location_config{$k};
    }
    say p(%location_config) if $self->debug;

    return \%location_config;
}

sub _require_handler_module {
    my $self    = shift;
    my $module  = shift;

    say "require($module)"
        if $self->debug;
    try {
        eval "require $module";
        if (my $e=$@) { die $e; }
    }
    catch ($e) {
        say "failed to require($module): $e";
        warn "failed to require($module): $e";
    }
}

sub _call_handler {
    my $self    = shift;
    my $plack   = shift;
    my $module  = shift;
    say "calling: $module"
        if $self->debug;

    my $res;
    try {
        if ($module->isa('Catalyst')) {
            say "$module is part of the Great Catalyst Hackup";
        }
        else {
            no strict 'refs';
            $res = &{"${module}::handler"}($plack)
                if $module->can('handler');
            say "no handler() in $module"
                unless $module->can('handler');
        }
    }
    catch ($e) {
        warn "$module->handler(): $e";
    }

    return $res;
}

sub _build_dispatches {
    my $self = shift;
    my $config = $self->parsed_apache_config;
    my @locations = $config->find_down_directive_names('Location');
    my @dispatches;

    LOCATION: foreach my $location (@locations) {
        DAUGHTER: foreach my $daughter ($location->daughters) {
            next
                unless $daughter->name =~ /perl.*handler/;

            my @handlers = $daughter->get_value_array;

            push @dispatches, {
                location        => $location->value,
                location_re     => _location_to_regexp($location->value),
                $daughter->name => \@handlers,
            };
        }
    }

    return \@dispatches;
}

sub _location_to_regexp {
    my $location = shift;
    my $match_re;

    # ' ~ ' locations are a regexpy match
    if ($location =~ s{\A\s*~\s+}{}) {
        # they sometimes are wrapped in douuble-quotes, so we'd better remove
        # them
        $location =~ s{\A"(.+)"\z}{$1};
        $match_re = qr{$location};
    }
    else {
        $match_re = qr{\A\Q$location\E(/|$)};
    }

    return $match_re;
}

__PACKAGE__->meta->make_immutable;
1;
