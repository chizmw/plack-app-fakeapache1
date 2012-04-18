package Plack::App::FakeModPerl1::Server;
use feature ':5.10';
use Carp;

sub new {
    my $class = shift;
    bless {@_}, $class;
}

our $AUTOLOAD;

sub AUTOLOAD {
    my $what = $AUTOLOAD;
    $what =~ s/.*:://;
    carp "!!server->$what(@_)" unless $what eq 'DESTROY';
}

sub dir_config {
    my ( $self, $c ) = @_;

    # Translate the legacy WebguiRoot and WebguiConfig PerlSetVar's into known values
    return $self->{env}->{'wg.WEBGUI_ROOT'} if $c eq 'WebguiRoot';
    return $self->{env}->{'wg.WEBGUI_CONFIG'} if $c eq 'WebguiConfig';

    # Otherwise, we might want to provide some sort of support (which Apache is still around)
    return $self->{env}->{"wg.DIR_CONFIG.$c"};
}

1;
