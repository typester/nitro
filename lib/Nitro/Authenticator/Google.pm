package Nitro::Authenticator::Google;
use Mouse;
use utf8;

use AnyEvent::HTTP;
use URI::Query;

has domain => (
    is      => 'ro',
    default => '',
);

no Mouse;

sub authenticate {
    my ($self, $username, $password, $cb) = @_;

    my $query = URI::Query->new(
        accountType => 'HOSTED_OR_GOOGLE',
        Email       => $username . $self->domain,
        Passwd      => $password,
    );

    http_post 'https://www.google.com/accounts/ClientLogin', $query->stringify,
        headers => { 'Content-Type' => 'application/x-www-form-urlencoded' }, sub {
            my ($body, $header) = @_;

            $cb->( $header->{Status} eq '200' );
        };
}

1;
