package Kukuru::Auth::Site::OAuth2;
use Mouse;
use LWP::UserAgent;
use Kukuru::Util;
use Kukuru::Util::OAuth2;

has [qw(client_id client_secret moniker site_authorize_uri site_access_token_uri)] => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has scope => (
    is => 'rw',
);

has _ua => (
    is => 'rw',
    default => sub {
        my $self = shift;
        LWP::UserAgent->new;
    },
);

has use_state => (
    is => 'rw',
    default => 1,
);

no Mouse;

sub auth_uri {
    my ($self, $c, %args) = @_;
    my $callback_uri = $args{callback}
        or die "Can't find 'callback'";

    my $uri   = URI->new($self->site_authorize_uri);
    my $state = Kukuru::Util::generate_random_string(32);

    $uri->query_form({
        response_type => 'code',
        client_id     => $self->client_id,
        redirect_uri  => "$callback_uri",
        $self->use_state ? (state => $state) : (),
        $self->scope     ? (scope => $self->scope) : (),
    });

    $c->session->set(oauth2_state => $state) if $self->use_state;
    $c->session->set(redirect_uri => "$callback_uri");
    return $uri->as_string;
}

sub callback {
    my ($self, $c, %callbacks) = @_;

    my $uri   = URI->new($self->site_access_token_uri);
    my $code  = $c->param('code');
    my $state = $c->param('state');
    my $session_state = $c->session->remove('oauth2_state');
    my $redirect_uri  = $c->session->remove('redirect_uri');
    my $on_finished   = $callbacks{on_finished} or die "Can't find 'on_finished'";
    my $on_error      = $callbacks{on_error}    or die "Can't find 'on_error'";

    if (!$code) {
        $c->app->exception_class->throw(
            message => "Can't find 'code' param",
            status  => 400,
        );
    }

    if ($self->use_state) {
        if (!$state) {
            $c->app->exception_class->throw(
                message => "Can't find 'state' param",
                status  => 400,
            );
        }
        elsif (!$redirect_uri || !$session_state || $state ne $session_state) {
            $c->app->exception_class->throw(
                message => "session error",
                status  => 400,
            );
        }
    }

    my $res = $self->_ua->post("$uri", [
        grant_type    =>'authorization_code',
        client_id     => $self->client_id,
        client_secret => $self->client_secret,
        redirect_uri  => $redirect_uri,
        code          => $code,
    ]);
    if (!$res->is_success) {
        return $on_error->($res->decoded_content);
    }

    my $params = Kukuru::Util::OAuth2::parse_content($res->decoded_content);
    return $on_finished->($params);
}

1;
