use strict;
use warnings;
use Test::More;
use Kukuru::Auth::Site::OAuth2;
use URI;

{
    package MyApp;
    use Mouse;
    extends 'Kukuru';
}

sub tx {
    my $req = Kukuru::Request->new({
        'psgix.session' => {},
        'psgix.session.options' => {},
    });

    Kukuru::Transaction->new(
        app   => MyApp->new(),
        req   => $req,
        match => {},
    );
}

subtest 'auth_uri' => sub {
    my $c = Kukuru::Controller->new(tx => tx());
    my $site = Kukuru::Auth::Site::OAuth2->new(
        client_id     => "aaaaaa",
        client_secret => "bbbbbb",
        moniker       => "test",
        site_authorize_uri    => "http://localhost/auth/",
        site_access_token_uri => "http://localhost/token",
    );
    my $uri = URI->new($site->auth_uri($c, callback => "http://localhost/"));

    my $query = {$uri->query_form};
    is $query->{response_type}, "code";
    is $query->{client_id}, "aaaaaa";
    is $query->{state}, $c->session->get("oauth2_state");
    is $query->{redirect_uri}, $c->session->get('redirect_uri');
};

done_testing;
