package Nitro::Backend::IRCD::Auth;
use utf8;
use Mouse;

use POE;
use POE::Component::Server::IRC::Plugin qw(:ALL);

sub PCSI_register {
    my ($self, $ircd) = @_;

    $ircd->plugin_register($self, 'SERVER', qw/raw_input/);

    no warnings 'redefine';
    my $orig = \&POE::Component::Server::IRC::_client_register;
    *POE::Component::Server::IRC::_client_register = sub {
        my ($ircd, $conn_id) = @_;

        my $conn = $ircd->{state}{conns}{ $conn_id } or return;
        return unless $conn->{_nitro_authorized};

        $orig->(@_);
    };

    use warnings;

    1;
}

sub PCSI_unregister {
    1;
}

sub IRCD_raw_input {
    my ($self, $ircd) = @_;

    my $conn_id = ${ $_[2] };
    my $input   = ${ $_[3] };

    if ($input =~ /^USER /) {
        my $user = $ircd->{state}{conns}{ $conn_id };
        my $nick = $ircd->_client_nickname($conn_id);

        my @cmd      = split /\s+/, $input;
        my $username = $cmd[1];

        if ($user and $nick and $username and !$user->{_nitro_authorized}) {
            if (!$user->{pass}) {
                $ircd->_terminate_conn_error(
                    $conn_id,
                    'Authorization required',
                );
            }
            else {
                Nitro->instance->authenticator->authenticate(
                    $username, $user->{pass}, sub {
                        if ($_[0]) {
                            $user->{_nitro_authorized} = 1;
                            $ircd->_client_register( $conn_id );
                        }
                        else {
                            $ircd->_terminate_conn_error(
                                $conn_id,
                                'You are not authorized to use this server',
                            );
                        }
                    },
                );
            }
        }
    }

    return PCSI_EAT_NONE;
}

1;
