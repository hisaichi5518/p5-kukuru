use strict;
use warnings;
use Test::More;

use Kukuru::Lite;

{
    package MyApp::Plugin::Test;

    sub init {
        my ($class, $app, @args) = @_;
        $app->{loaded_plguin}++;
    }
}

subtest 'app isa __PACKAGE__' => sub {
    isa_ok app, __PACKAGE__;
};

subtest 'add plugin' => sub {
    ok !app->{loaded_plguin};

    plugin "+MyApp::Plugin::Test";

    ok app->{loaded_plguin};
};

subtest "has routes methods" => sub {
    for my $method (qw(any get patch post put del)) {
        can_ok __PACKAGE__, $method;
    }
};

subtest 'can add routes?' => sub {
    is scalar(@{app->router->routes}), 0;

    get '/' => sub {};

    is scalar(@{app->router->routes}), 1;
};

done_testing;
