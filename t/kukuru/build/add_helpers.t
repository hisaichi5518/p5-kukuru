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
    use Test::More;
    extends 'Kukuru::Controller';
}


my $app = MyApp->new;
sub tx {
    my $req = Kukuru::Request->new({});

    Kukuru::Transaction->new(
        app   => $app,
        req   => $req,
        match => undef,
    );
}

my $c = MyApp::Controller->new(
    app  => tx()->app,
    tx   => tx(),
    args => {},
);

is $c->fly, 1;

eval { MyApp::Controller->not_found_method() };
ok $@;
like $@, qr/Undefined subroutine/;

eval { $c->not_found_method };
ok $@;
like $@, qr/Can't locate object method/;



done_testing;
