use strict;
use warnings;
use Test::More;
use Kukuru::Auth::Site::Nakamap;

subtest 'new' => sub {
    my $site = Kukuru::Auth::Site::Nakamap->new(
        client_id     => "aaaaaaa",
        client_secret => "aaaaaaa",
    );

    is $site->moniker, "nakamap";
    is $site->site_authorize_uri, "https://nakamap.com/dialog/oauth";
    is $site->site_access_token_uri, "https://thanks.nakamap.com/oauth/access_token";
    is $site->use_state, 0;
};

done_testing;
