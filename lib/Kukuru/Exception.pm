package Kukuru::Exception;
use Mouse;
use overload q[""] => \&stringify, fallback => 1;

has [qw/message file line/] => (
    is => 'rw',
);

has status => (
    is => 'rw',
    default => 500,
);

no Mouse;

sub throw {
    my ($class, %args) = @_;
    my $message = $args{message};
    my $status  = $args{status};
    my $file    = $args{file};
    my $line    = $args{line};

    die $class->new(
        message => $message,
        ($status ? (status  => $status) : ()),
        ($file   ? (file    => $file)   : ()),
        ($line   ? (line    => $line)   : ()),
    );
}

sub croak {
    my ($class, $message) = @_;

    my @caller = caller(1);
    $class->throw(
        message => $message || 'Died.',
        status  => 500,
        file    => $caller[1],
        line    => $caller[2],
    );
}

sub croakf {
    my ($self, $format, @args) = @_;

    # callerをあれこれするためにこうする
    @_ = ($self, sprintf $format, @args);
    goto \&croak;
}

sub stringify {
    my ($self) = @_;

    if ($self->file && $self->line) {
        sprintf '%s at %s line %d.', $self->message, $self->file, $self->line;
    }
    else {
        sprintf '%s', $self->message;
    }
}

1;
