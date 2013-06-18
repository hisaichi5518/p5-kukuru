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
            $self->render(text => encode_utf8 'あいうえお');
        });

        $self->router->get('/text-string' => sub {
            my ($self) = @_;
            $self->render(text => 'あいうえお');
        });

        $self->router->get('/override-status' => sub {
            my ($self) = @_;
            $self->render(text => 'あいうえお', status => 500);
        });

        $self->router->get('/override-type' => sub {
            my ($self) = @_;
            $self->render(text => 'あいうえお', type => "text/html; charset=UTF-8");
        });

        $self->router->get('/override-format' => sub {
            my ($self) = @_;
            $self->render(text => 'あいうえお', format => "html");
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

        subtest 'status is 200' => sub {
            my $res = $cb->(GET '/text-string');
            is $res->code, 200;
        };

        subtest 'status is 500' => sub {
            my $res = $cb->(GET '/override-status');
            is $res->code, 500;
            is $res->content, encode_utf8 "あいうえお";
        };

        subtest 'type is "text/html; charset=UTF-8"' => sub {
            my $res = $cb->(GET '/override-type');
            is $res->headers->header('Content-Type'), "text/html; charset=UTF-8";
        };

        subtest 'format is html' => sub {
            my $res = $cb->(GET '/override-format');
            is $res->headers->header('Content-Type'), "text/html; charset=UTF-8";
        };

        subtest 'content-length' => sub {
            my $res = $cb->(GET '/text-string');
            my $content = encode_utf8 "あいうえお";
            is $res->content_length, length($content);
        };
    };

done_testing;
