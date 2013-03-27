use strict;
use warnings;
use Test::More;

{
    package MyApp;
    use Mouse;
    extends 'Kukuru';

    sub startup {
        my ($self) = @_;
        $self->helpers->{fly} = sub {
            my $c = shift;
            return 1;
        };
    }

    package MyApp::Controller;
    use Mouse;
    extends 'Kukuru::Controller';

    sub index {}
}

use Kukuru::Test;
use HTTP::Request::Common;
test_app
    app => MyApp->new(),
    client => sub {
        my ($cb) = @_;
        my ($res, $tx) = $cb->(GET '/');
        my $c = $tx->_last_controller_object;
        is $c->fly, 1;

        eval { MyApp::Controller->not_found_method };
        ok $@;
        like $@, qr/Undefined subroutine/;

        eval { $c->not_found_method };
        ok $@;
        like $@, qr/Can't locate object method/;
    };

done_testing;
