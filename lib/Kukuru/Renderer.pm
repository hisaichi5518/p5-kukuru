package Kukuru::Renderer;
use strict;
use warnings;

use Kukuru::Renderer::Template;
use Kukuru::Renderer::Exception;
use Kukuru::Renderer::Text;
use Kukuru::Renderer::JSON;
use Kukuru::Renderer::Data;

use Mouse;
use Carp ();

has [qw(handlers engines)] => (
    is => 'rw',
    default => sub { +{} },
);

no Mouse;

sub BUILD {
    my ($self) = @_;

    $self->add_handler(template => \&Kukuru::Renderer::Template::handler);
    $self->add_handler(text     => \&Kukuru::Renderer::Text::handler);
    $self->add_handler(json     => \&Kukuru::Renderer::JSON::handler);
    $self->add_handler(data     => \&Kukuru::Renderer::Data::handler);

    $self->add_handler(exception => \&Kukuru::Renderer::Exception::handler);
}

sub add_handler {
    my ($self, $name, $code) = @_;

    $self->handlers->{$name} = $code;
}

sub render {
    my ($self, $tx, $c, @vars) = @_;
    my %handlers = %{$self->handlers};
    my %vars     = @vars;

    my $code;
    if (my $handler = $vars{handler}) {
        $code = $self->handlers->{$handler};
    }
    else {
        for my $i (0..$#vars/2) {
            my $key = $vars[$i * 2];
            if ($self->handlers->{$key}) {
                $code = $self->handlers->{$key};
                $vars{handler} = $key;
                last;
            }
        }
    }

    if (ref $code eq 'CODE') {
        $code->($tx, $c, %vars);
    }
    else {
        # TODO: level
        Carp::croak(qq!No handler for "$vars{handler}" available!);
    }
}

__PACKAGE__->meta->make_immutable;
