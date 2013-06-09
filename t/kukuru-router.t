use strict;
use warnings;
use utf8;
use Test::More;
use Kukuru::Router;

subtest '_build_dest' => sub {
    my $router = Kukuru::Router->new;

    my $dest = $router->_build_dest(
        { controller => 'Root', action => 'index' },
    );

    is_deeply $dest, {controller => 'Root', action => 'index'};
};

subtest '_build_dest' => sub {
    my $router = Kukuru::Router->new;
    my $dest = $router->_build_dest(
        'Root#index',
    );

    is_deeply $dest, {controller => 'Root', action => 'index'};
};

subtest '_build_dest' => sub {
    my $router = Kukuru::Router->new;
    my $dest = $router->_build_dest(
        ['Root#index1', 'Root#index2'],
    );

    is_deeply $dest, {action => [
        {controller => 'Root', action => 'index1'},
        {controller => 'Root', action => 'index2'},
    ]};
};

subtest 'add_child' => sub {
    my $router1 = Kukuru::Router->new;
    my $route   = $router1->get('/' => 'Root#index');

    my $router2 = Kukuru::Router->new;
    $router2->add_child($route);

    is scalar(@{$router2->routes}), 1;
};

subtest 'add_route' => sub {
    my $router = Kukuru::Router->new;
    my $dest = $router->add_route(
        GET => '/',
        'Root#index',
        {on_match => sub {}},
    );

    is @{$router->routes}, 1;
    my $route = $router->routes->[0];

    is_deeply $route->{dest}, {controller => 'Root', action => 'index'};
    ok $route->{on_match};
};

subtest 'get, patch, post, put, del' => sub {
    my $router = Kukuru::Router->new;
    $router->get('/', 'Root#index');
    $router->patch('/', 'Root#index');
    $router->post('/', 'Root#index');
    $router->put('/', 'Root#index');
    $router->del('/', 'Root#index');

    is @{$router->routes}, 5;
    is_deeply $router->routes->[0]->{method}, [qw/GET HEAD/];
    is_deeply $router->routes->[1]->{method}, [qw/PATCH/];
    is_deeply $router->routes->[2]->{method}, [qw/POST/];
    is_deeply $router->routes->[3]->{method}, [qw/PUT/];
    is_deeply $router->routes->[4]->{method}, [qw/DELETE/];
};

subtest 'error' => sub {
    my $router = Kukuru::Router->new;
    eval { $router->get('/', 'test') };
    like $@, qr/Can't find action at route/;
};

subtest 'routes' => sub {
    my $router = Kukuru::Router->new;
    is ref $router->routes, 'ARRAY';
    ok !scalar(@{$router->routes});

    $router->get('/' => sub {});

    is ref $router->routes, 'ARRAY';
    ok scalar(@{$router->routes});
};

done_testing;
