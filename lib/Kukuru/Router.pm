package Kukuru::Router;
use strict;
use warnings;
use parent 'Router::Simple';
use Carp ();

sub routes { shift->{routes} }

sub any {
    my $self = shift;
    $self->add_route(@_);
}

sub get {
    my $self = shift;
    $self->add_route([qw(GET HEAD)], @_);
}

sub patch {
    my $self = shift;
    $self->add_route([qw(PATCH)], @_);
}

sub post {
    my $self = shift;
    $self->add_route([qw(POST)], @_);
}

sub put {
    my $self = shift;
    $self->add_route([qw(PUT)], @_);
}

sub del {
    my $self = shift;
    $self->add_route([qw(DELETE)], @_);
}

sub add_route {
    my ($self, $method, $path, $dest, $opts) = @_;

    if (!$method || !$path || !$dest) {
        Carp::croak('required method/path/dest');
    }

    $opts ||= {};
    $opts->{method} = $method;

    $dest = $self->_build_dest($dest);
    if (!$dest->{action}) {
        Carp::croak("Can't find action at route");
    }

    $self->connect($path, $dest, $opts);
}

sub add_child {
    my ($self, $route) = @_;

    push @{$self->routes}, $route;
}

sub load_routes {
    # TODO: my @routes = Kukuru::Util::find_routes(useall 'MyApp::Routes');
    # $router->add_child($_) for @routes;
    my ($self, @apps) = @_;

    for my $app_class (@apps) {
        for my $route (@{$app_class->app->router->routes}) {
            $self->add_child($route);
        }
    }
}

sub _build_dest {
    my ($self, $dest) = @_;

    my $dest_type = ref $dest;
    if ($dest_type eq 'CODE') {
        return {action => $dest};
    }
    elsif ($dest_type eq 'ARRAY') {
        my @dests = map { $self->_build_dest($_) } @$dest;
        return {action => \@dests};
    }
    elsif (!$dest_type) {
        my ($controller, $action) = split '#', $dest;
        return {controller => $controller, action => $action};
    }

    return $dest;
}

1;
