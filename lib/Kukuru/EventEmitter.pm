package Kukuru::EventEmitter;
use strict;
use warnings;
use Mouse;

has events => (
    is => 'rw',
    default => sub { +{} },
);

no Mouse;

sub on {
    my ($self, $name, $code) = @_;
    push @{$self->events->{$name} ||= []}, $code;
    $code;
}

sub emit {
    my ($self, $name, @args) = @_;
    if (my $s = $self->subscribers($name)) {
        for my $code (@$s) {
            $code->($self, @args);
        }
    }
}

sub has_subscribers {
    my ($self, $name) = @_;
    @{$self->subscribers($name)} ? 1 : 0;
}

sub subscribers {
    my ($self, $name) = @_;
    $self->events->{$name} || [];
}

sub unsubscribe {
    my ($self, $name) = @_;

    if (my $s = $self->subscribers($name)) {
        delete $self->events->{$name};
    }
}

1;
