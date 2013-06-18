use strict;
use warnings;
use utf8;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use Encode;

{
    package MyApp;
    use Mouse;
    BEGIN { extends 'Kukuru' };

    no Mouse;
    use Encode;

    sub startup {
        my ($self) = @_;

        $self->router->get('/byte-string' => sub {
            my ($self) = @_;
            $self->render(exception => encode_utf8 'あいうえお');
        });

        $self->router->get('/text-string' => sub {
            my ($self) = @_;
            $self->render(exception => 'あいうえお');
        });

        $self->router->get('/override-status' => sub {
            my ($self) = @_;
            $self->render(exception => 'あいうえお', status => 400);
        });
    }
}

my $app = eval { MyApp->to_psgi };
ok !$@;

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;

        subtest 'argument byte-string' => sub {
            my $res = $cb->(GET '/byte-string');
            isnt $res->content, encode_utf8 "あいうえお";
        };

        subtest 'argument text-string' => sub {
            my $res = $cb->(GET '/text-string');
            is $res->headers->header('Content-Type'), "text/plain; charset=UTF-8";
            is $res->content, encode_utf8 "あいうえお";
        };

        subtest 'status is 500' => sub {
            my $res = $cb->(GET '/text-string');
            is $res->code, 500;
        };

        subtest 'status is 400' => sub {
            my $res = $cb->(GET '/override-status');
            is $res->code, 400;
            is $res->content, encode_utf8 "あいうえお";
        };
    };

done_testing;
