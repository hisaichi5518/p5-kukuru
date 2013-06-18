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
            $self->render(json => {foo => encode_utf8 "あいうえお"});
        });

        $self->router->get('/text-string' => sub {
            my ($self) = @_;
            $self->render(json => {foo => "あいうえお"});
        });
    }
}

my $app = eval { MyApp->to_psgi };
ok !$@;

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;

        subtest 'arguments byte-string' => sub {
            my $res = $cb->(GET '/byte-string');
            isnt $res->content, '{"foo":"\u3042\u3044\u3046\u3048\u304a"}';
        };

        subtest 'arguments text-string' => sub {
            my $res = $cb->(GET '/text-string');
            is $res->content_length, 40;
            is $res->content, '{"foo":"\u3042\u3044\u3046\u3048\u304a"}';
        };

        subtest 'json hijacking' => sub {
            my $res = $cb->(GET '/text-string',
                'User-Agent' => "android",
                'Cookie'     => 'i have cookie!',
            );
            is $res->code, 403;
            is $res->headers->header('Content-Type'), 'text/plain; charset=UTF-8';
            like $res->content, qr/Your request may be JSON hijacking/;
        };

        subtest 'not json hijacking' => sub {
            my $res = $cb->(GET '/text-string',
                'User-Agent' => "android",
                'Cookie'     => 'i have cookie!',
                'X-Requested-With' => 'XMLHttpRequest',
            );
            is $res->content, '{"foo":"\u3042\u3044\u3046\u3048\u304a"}';
        };

        subtest 'UTF-8 BOM' => sub {
            my $res = $cb->(GET '/text-string',
                'User-Agent' => "Safari",
            );
            is $res->content_length, 46;
            isnt $res->content, '{"foo":"\u3042\u3044\u3046\u3048\u304a"}';
        };

        subtest 'has "Content-Type"' => sub {
            my $res = $cb->(GET '/text-string');
            is $res->header('Content-Type'), 'application/json; charset=UTF-8';
        };

        subtest 'has "X-Content-Type-Options"' => sub {
            my $res = $cb->(GET '/text-string');
            is $res->header('X-Content-Type-Options'), 'nosniff';
        };
    };

done_testing;
