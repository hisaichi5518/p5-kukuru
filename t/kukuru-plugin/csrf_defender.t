use strict;
use warnings;
use Test::More;

{
    package MyApp;
    use Mouse;
    extends "Kukuru";
    no Mouse;
    use Text::Xslate;

    sub startup {
        my ($self) = @_;
        $self->template_engine(
            Text::Xslate->new(
                path => [{index => qq!<form action="/" method="post">!}],
            )
        );
        $self->load_plugin('CSRFDefender');
        $self->router->get('/' => sub {
            my ($c) = @_;
            $c->render('index');
        });

        $self->router->post('/post' => sub {
            my ($c) = @_;
            $c->render(text => 'ok');
        });
    }
}

use Plack::Builder;
use Plack::Test;
use HTTP::Request::Common;
use HTTP::Cookies;

my $app = builder {
    enable "Session";
    MyApp->to_psgi;
};

subtest 'csrf_defender' => sub {

    test_psgi
        app => $app,
        client => sub {
            my ($cb) = @_;
            my $jar = HTTP::Cookies->new;
            my $res = $cb->(GET '/');

            $jar->extract_cookies($res);
            like $res->content, qr/<input type="hidden" name="__csrf_token" value="(.+)" \/>/;

            $res->content =~ m/<input type="hidden" name="__csrf_token" value="(.+)" \/>/;
            my $req = POST 'http://localhost/post', [__csrf_token => $1];
            $jar->add_cookie_header($req);

            $res = $cb->($req);
            is $res->content, 'ok';
        };
};

done_testing;
