package Kukuru;
use 5.10.1;
use strict;
use warnings;

our $VERSION = "0.01";

use Kukuru::Request;
use Kukuru::Controller;
use Kukuru::Router;
use Kukuru::Util;
use Kukuru::Renderer;
use Kukuru::Transaction;
use Kukuru::Exception;

use Mouse;

has router => (
    is => 'rw',
    default => sub { Kukuru::Router->new },
);

has helpers => (
    is => 'rw',
    default => sub { +{} },
);

has hooks => (
    is => 'rw',
    default => sub { +{} },
);

has renderer => (
    is => 'rw',
    default => sub { Kukuru::Renderer->new }
);

has template_engine => (
    is => 'rw',
);

has lint => (
    is => 'rw',
    default => 1,
);

has default_headers => (
    is => 'rw',
    default => sub {
        [
            "X-XSS-Protection"       => "1; mode=block",
            "X-Frame-Options"        => "SAMEORIGIN",
            "X-Content-Type-Options" => "nosniff",
        ];
    },
);

no Mouse;

sub BUILD {
    my ($self) = @_;

    # auto-build controller if fail load "app_controller_class"
    if (Kukuru::Util::try_load_one_class($self->app_controller_class)) {
        my $meta = Mouse->init_meta(for_class => $self->app_controller_class);
        $meta->superclasses($self->controller_class);
    }

    # startup
    $self->startup;

    # add helpers for "app_controller_class"
    my $meta = $self->app_controller_class->meta;
    for my $name (keys %{$self->helpers}) {
        $meta->add_method($name => $self->helpers->{$name});
    }

    if ($self->lint) {
        # lint your application routes
        # - app_controller_classにKukuru::Controllerが継承されているか
        # - Controllerにextendsされているか
        # - Controllerの中にactionがあるか
    }
}

sub to_psgi {
    my $class = shift;
    my $self  = blessed $class ? $class : $class->new;

    sub {
        my $env   = shift;
        my $match = $self->router->match($env);
        my $tx = Kukuru::Transaction->new(
            app   => $self,
            req   => $self->request_class->new($env),
            match => $match,
        );
        $tx->dispatch->finalize;
    };
}

sub load_plugin {
    my ($self, $plugin, $options) = @_;
    my $klass = Kukuru::Util::load_class($plugin, 'Kukuru::Plugin');

    $klass->init($self, $options || {});
}

sub add_hook {
    my ($self, $name, $code) = @_;
    push @{$self->hooks->{$name} ||= []}, $code;
}

sub emit_hook {
    my ($self, $name, @args) = @_;
    my @codes = $self->find_hook_codes($name);

    for my $code (@codes) {
        $code->($self, @args);
    }
}

sub find_hook_codes {
    my ($self, $name) = @_;

    @{$self->hooks->{$name} || []};
}

sub startup {}

sub request_class    { 'Kukuru::Request'    }
sub controller_class { 'Kukuru::Controller' }
sub exception_class  { 'Kukuru::Exception'  }

sub app_controller_class { shift->meta->name."::Controller" }

__PACKAGE__->meta->make_immutable;
__END__

=head1 NAME

Kukuru - yet anothor Web Application Framework

=head1 AUTHOR

hisaichi5518 E<lt>hisaichi5518 @ gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
