package Kukuru::Controller;
use strict;
use warnings;

use Carp ();
use Mouse;

has [qw(tx)] => (
    is => 'rw',
    required => 1,
);

has match => (
    is => 'rw',
);

no Mouse;

sub req { shift->tx->req }
sub app { shift->tx->app }

# TODO: render_*
# render_template, render_action, render_file, render_data, render_text
sub render {
    my $self = shift;
    my $template;
    if (@_ % 2) {
        $template = shift;
    }

    my %vars = @_;
    if ($template) {
        $vars{template} = $template;
    }

    $self->app->renderer->render($self, %vars);
}

# TODO: send_*系
# send_file, send_data


sub redirect {
    my ($self, $uri, $status) = @_;

    if (ref $uri eq 'ARRAY') {
        $uri = $self->uri_with($uri);
    }
    else {
        $uri = $self->uri_for($uri);
    }

    $self->req->new_response(
        $status || 302,
        ['Location' => "$uri"],
        [],
    );
}

sub uri_for {
    my ($self, $path, $params) = @_;
    my $uri = $self->req->base;
    $path = $uri->path eq '/' ? $path : $uri->path.$path;

    $uri->path($path);
    my $enc = $self->req->encoding;
    $uri->query_form(map { $enc->encode($_) } @$params) if $params;

    $uri;
}

sub uri_with {
    my ($self, $params) = @_;
    my $uri = $self->req->uri;

    my $enc = $self->req->encoding;
    $uri->query_form(map { $enc->encode($_) } @$params) if $params;

    $uri;
}

sub param     { shift->req->param(@_)     }
sub param_raw { shift->req->param_raw(@_) }
sub session   { shift->req->session(@_)   }

sub flash {
    my ($self, $key, $val) = @_;

    my $now_key = '__kukuru_flash';
    my $now_val = $self->session->get($now_key) || {};

    if (defined $key && defined $val) {
        my $new_key = '__kukuru_flash_new';
        my $new_val = $self->session->get($new_key) || {};

        $new_val->{$key} = $val;
        $self->session->set($new_key => $new_val);
        return $new_val->{$key};
    }
    elsif (defined $key) {
        return $now_val->{$key};
    }

    Carp::croak('need key for flash');
}

sub dispatch {
    my ($self, $match) = @_;
    # $match # => {:controller => Str, :action => Str || CodeRef}
    if ($match) {
        my $action = $match->{action};

        if ($action && ref $action eq 'CODE') {
            return $action->($self);
        }
        elsif ($action && $self->can($action)) {
            return $self->$action();
        }
        elsif ($action) {
            return $self->render(
                status => 404,
                text   => "Not Found Action($action)",
            );
        }
    }

    $self->render(
        status => 404,
        text   => 'Not Found Page',
    );
}

__PACKAGE__->meta->make_immutable;
