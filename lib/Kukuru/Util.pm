package Kukuru::Util;
use strict;
use warnings;
use Mouse::Util;
use Plack::MIME;

sub load_class {
    my ($klass, $prefix) = @_;

    if ($prefix) {
        unless ($klass =~ s/^\+// || $klass =~ /^$prefix/) {
            $klass = "$prefix\::$klass";
        }
    }

    Mouse::Util::load_class($klass);
}

sub find_content_type {
    my (%args) = @_;
    my $format  = $args{format} or Carp::croak("require format.");
    my $charset = $args{charset};

    my $type = Plack::MIME->mime_type(".$format");

    # MIME implementations must ignore any parameters
    # whose names they do not recognize.
    $type .= "; charset=$charset" if $charset;

    $type;
}

sub try_load_one_class {
    my ($klass) = @_;

    Mouse::Util::_try_load_one_class($klass);
}

sub generate_random_string {
    my ($max) = @_;

    my $random_str;
    my @chars = ('a'..'z', 'A'..'Z', 0..9);
    for (0..$max) {
        $random_str .= $chars[int rand @chars];
    }

    $random_str;
}


1;
