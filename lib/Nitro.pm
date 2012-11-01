package Nitro;
use utf8;
use Mouse;

use Nitro::Config;
use Nitro::Types;

use AnyEvent;

has config => (
    is       => 'ro',
    isa      => 'Nitro::Config',
    required => 1,
    coerce   => 1,
);

has [qw/authenticator backend/] => (
    is => 'rw',
);

has _cv => (
    is => 'rw',
);

no Mouse;

sub BUILD {
    my ($self) = @_;
    $self->setup;
}

{
    my $instance;
    sub instance {
        shift;
        return $instance unless @_;
        $instance = $_[0];
    }
}

sub run {
    my ($self) = @_;

    $self->instance($self);
    $self->backend->run;

    $self->_cv( AnyEvent->condvar );
    $self->_cv->recv;
}

sub stop {
    my ($self) = @_;

    $self->backend->stop;
    $self->_cv->send;
}

sub setup {
    my ($self) = @_;

    $self->setup_authenticator;
    $self->setup_backend;
}

sub setup_authenticator {
    my ($self) = @_;

    my $conf = $self->config->authenticator;

    my $class = 'Nitro::Authenticator::' . $conf->{class};
    Mouse::load_class($class);
    my $authenticator = $class->new($conf->{config});
    $self->authenticator($authenticator);
}

sub setup_backend {
    my ($self) = @_;

    my $conf = $self->config->backend;

    my $class = 'Nitro::Backend::' . $conf->{class};
    Mouse::load_class($class);
    my $backend = $class->new($conf->{config});
    $self->backend($backend);
}

1;
