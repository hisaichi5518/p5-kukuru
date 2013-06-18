use strict;
use warnings;
use utf8;
use Test::More;
use Kukuru::Exception;

isa_ok "Kukuru::Exception", "Exception::Tiny";

done_testing;
