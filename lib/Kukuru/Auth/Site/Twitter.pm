package Kukuru::Auth::Site::Twitter;
use Mouse;
use Net::Twitter::Lite;

sub moniker { "twitter" }

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

has _nt => (
    is => 'rw',
    default => sub {
        my $self = shift;
        Net::Twitter::Lite->new(
            consumer_key    => $self->consumer_key,
            consumer_secret => $self->consumer_secret,
            legacy_lists_api => 0,
        );
    },
);

no Mouse;

sub auth_uri {
    my ($self, $c, %args) = @_;
    my $callback_uri = $args{callback};
    my $nt           = $self->_nt;
    my $redirect_uri = $nt->get_authorization_url(callback => $callback_uri);

    $c->session->set(request_token => $nt->request_token);
    $c->session->set(request_token_secret => $nt->request_token_secret);

    return $redirect_uri;
}

sub callback {
    my ($self, $c, %callbacks) = @_;
    my $on_finished = $callbacks{on_finished} or die "Can't find 'on_finished'";
    my $on_error    = $callbacks{on_error}    or die "Can't find 'on_error'";

    if ($c->param("denied")) {
        return $callbacks{on_error}->("denied");
    }

    my $request_token        = $c->session->remove('request_token');
    my $request_token_secret = $c->session->remove('request_token_secret');

    if (!$request_token || !$request_token_secret) {
        return $callbacks{on_error}->("Session error");
    }

    my $nt = $self->_nt;
    $nt->request_token($request_token);
    $nt->request_token_secret($request_token_secret);

    my $verifier = $c->param('oauth_verifier');
    my ($access_token, $access_token_secret, $user_id, $screen_name) = eval {
        $nt->request_access_token(verifier => $verifier);
    };
    if ($@) {
        return $on_error->($@);
    }

    return $on_finished->(
        $access_token, $access_token_secret, $user_id, $screen_name
    );
}

1;
