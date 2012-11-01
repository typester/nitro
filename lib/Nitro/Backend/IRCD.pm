package Nitro::Backend::IRCD;
use utf8;
use Mouse;

use POE;
use POE::Component::Server::IRC; # want AnyEvent IRC Server

use Nitro::Backend::IRCD::Auth;

has port => (
    is      => 'ro',
    isa     => 'Int',
    default => 6667,
);

has _session => (
    is => 'rw',
);

has _ircd => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my $ircd = POE::Component::Server::IRC->spawn(
            debug => 1,
            auth  => 0,
        );
        $ircd->plugin_add('NitroAuth', Nitro::Backend::IRCD::Auth->new);

        $ircd;
    },
);

no Mouse;

sub run {
    my ($self) = @_;

    my $session = POE::Session->create(
        object_states => [ $self => {
            _start   => 'poe_start',
            _default => 'poe_default',
        }],
    );
}

sub stop {
    POE::Kernel->stop;
}

sub poe_start {
    my ($self) = @_;

    my $ircd = $self->_ircd;
    $ircd->yield( register => 'all' );

    $ircd->add_auth(mask => '*@*');
    $ircd->add_listener( port => $self->port );
}

sub poe_default {
    my $self = $_[OBJECT];
    my @args = @_[ARG0 .. $#_];

    use YAML;
    warn $self;
    warn Dump \@args;
}

1;
