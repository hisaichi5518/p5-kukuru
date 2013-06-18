package Kukuru::Auth::Site::Zaim;
use Mouse;
use OAuth::Lite::Consumer;

sub moniker { "zaim" }

has consumer_key => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has consumer_secret => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has _consumer => (
    is => 'rw',
    default => sub {
        my $self = shift;
        OAuth::Lite::Consumer->new(
            consumer_key       => $self->consumer_key,
            consumer_secret    => $self->consumer_secret,
            site               => q{https://api.zaim.net/v1},
            request_token_path => q{/auth/request},
            access_token_path  => q{/auth/access},
            authorize_path     => q{https://www.zaim.net/users/auth},
        );
    },
);

no Mouse;

sub auth_uri {
    my ($self, $c, %args) = @_;
    my $callback_uri  = $args{callback};
    my $request_token = $self->_consumer->get_request_token(
        callback_url => "$callback_uri",
    ) or die $self->_consumer->errstr;

    $c->session->set(request_token => $request_token);

    $self->_consumer->url_to_authorize(token => $request_token);
}

sub callback {
    my ($self, $c, %callbacks) = @_;
    my $on_finished   = $callbacks{on_finished} or die "Can't find 'on_finished'";
    my $on_error      = $callbacks{on_error}    or die "Can't find 'on_error'";
    my $verifier      = $c->param('oauth_verifier');
    my $request_token = $c->session->remove('request_token');

    my $access_token = eval {
        $self->_consumer->get_access_token(
            token    => $request_token,
            verifier => $verifier,
        );
    };
    if ($@) {
        return $on_error->($@);
    }

    return $on_finished->($access_token);
}

1;
