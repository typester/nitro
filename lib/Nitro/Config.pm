package Nitro::Config;
use utf8;
use Mouse;

has authenticator => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub {
        return {
            class  => 'Google',
            config => { },
        };
    },
);

has backend => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub {
        return {
            class  => 'IRCD',
            config => {
                port => 6667,
            },
        };
    },
);

1;
