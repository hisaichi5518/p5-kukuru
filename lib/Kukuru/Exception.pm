package Kukuru::Exception;
use strict;
use warnings;
use parent "Exception::Tiny";

use Class::Accessor::Lite (
    ro  => [qw/status/]
);

1;
