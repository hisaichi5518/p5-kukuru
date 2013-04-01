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
    use File::Spec;
    use File::Basename qw(dirname);
    use Test::More;
    use Text::Xslate;

    sub startup {
        my ($self) = @_;

        $self->renderer->engines->{template} = do {
            Text::Xslate->new(
                path => [File::Spec->catdir(dirname(__FILE__), 'views')],
            );
        };

        $self->add_hook('html_filter' => sub {
            my ($app, $tx, $output) = @_;
            $$output = "html-filter" if $tx->req->path_info eq '/html-filter';
        });

        $self->router->get('/byte-string' => sub {
            my ($self) = @_;
            $self->render(
                template => 'template.tx',
                foo      => encode_utf8 "あいうえお",
            );
        });

        $self->router->get('/text-string' => sub {
            my ($self) = @_;
            $self->render(
                template => 'template.tx',
                foo      => "あいうえお",
            );
        });

        $self->router->get('/override-status' => sub {
            my ($self) = @_;
            $self->render('template.tx',
                foo    => 'あいうえお',
                status => 500,
            );
        });

        $self->router->get('/override-type' => sub {
            my ($self) = @_;
            $self->render('template.tx',
                foo  => 'あいうえお',
                type => "text/plain; charset=UTF-8",
            );
        });

        $self->router->get('/override-format' => sub {
            my ($self) = @_;
            $self->render('template.tx',
                foo    => 'あいうえお',
                format => "text",
            );
        });

        $self->router->get('/html-filter' => sub {
            my ($self) = @_;
            $self->render('template.tx',
                foo    => 'あいうえお',
                format => "text",
            );
        });
    }
}

my $app = eval { MyApp->to_psgi };
ok !$@;
warn $@ if $@;


test_psgi
    app => $app,
    client => sub {
        my $cb = shift;

        subtest '/byte-string' => sub {
            my $res = $cb->(GET '/byte-string');
            is $res->content, encode_utf8 "あいうえおあいうえお\n";
        };

        subtest '/text-string' => sub {
            my $res = $cb->(GET '/text-string');
            is $res->content, encode_utf8 "あいうえおあいうえお\n";
        };

        subtest 'status is 200' => sub {
            my $res = $cb->(GET '/text-string');
            is $res->code, 200;
        };

        subtest 'status is 500' => sub {
            my $res = $cb->(GET '/override-status');
            is $res->code, 500;
            is $res->content, encode_utf8 "あいうえおあいうえお\n";
        };

        subtest 'fotmat is text' => sub {
            my $res = $cb->(GET '/html-filter');
            is $res->content, "html-filter";
        };

        subtest 'type is "text/plain; charset=UTF-8"' => sub {
            my $res = $cb->(GET '/override-type');
            is $res->headers->header('Content-Type'), "text/plain; charset=UTF-8";
            is $res->content, encode_utf8 "あいうえおあいうえお\n";
        };

        subtest 'fotmat is text' => sub {
            my $res = $cb->(GET '/override-format');
            is $res->headers->header('Content-Type'), "text/plain; charset=UTF-8";
        };

        subtest 'content-length' => sub {
            my $res = $cb->(GET '/text-string');
            my $content = encode_utf8 "あいうえおあいうえお\n";
            is $res->content_length, length($content);
        };
    };

done_testing;
