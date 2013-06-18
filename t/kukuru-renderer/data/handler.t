use strict;
use warnings;
use utf8;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;

{
    package MyApp;
    use Test::More;
    use Mouse;
    BEGIN { extends 'Kukuru' };
    no Mouse;
    use File::Spec;

    sub read_file {
        open my $fh, '<', File::Spec->catfile('lib/Kukuru.pm') or fail $!;
        return $fh;
    }

    sub startup {
        my ($self) = @_;

        $self->router->get('/read-file' => sub {
            my ($c) = @_;
            $c->render(data => $self->read_file, format => "pm");
        });

        $self->router->get('/override-type' => sub {
            my ($c) = @_;
            $c->render(
                data => $self->read_file,
                type => 'text/plain; charset=shift_jis',
            );
        });

        $self->router->get('/error' => sub {
            my ($c) = @_;
            $c->render(
                data => $self->read_file,
            );
        });
    }
}

my $app = eval { MyApp->to_psgi() };
ok !$@;

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        subtest 'can read file?' => sub {
            my $res = $cb->(GET '/read-file');
            like $res->content, qr/package Kukuru;/;
        };

        subtest 'override format' => sub {
            my $res = $cb->(GET '/read-file');
            is $res->header('Content-Type'), 'text/x-script.perl-module; charset=UTF-8';
        };

        subtest 'override type' => sub {
            my $res = $cb->(GET '/override-type');
            is $res->header('Content-Type'), 'text/plain; charset=shift_jis';
        };

        subtest 'error' => sub {
            my $res = $cb->(GET '/read-file');
            ok $res->content_length;
        };

        subtest 'error' => sub {
            my $res = $cb->(GET '/error');
            is $res->code, 500;
            like $res->content, qr{need type/format};
        };
    };

done_testing;
