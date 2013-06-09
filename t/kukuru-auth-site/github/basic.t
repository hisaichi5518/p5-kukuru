use strict;
use warnings;
use Test::More;
use Kukuru::Auth::Site::Github;

subtest 'new' => sub {
    my $site = Kukuru::Auth::Site::Github->new(
        client_id     => "aaaaaaa",
        client_secret => "aaaaaaa",
    );
    is $site->moniker, "github";
    is $site->site_authorize_uri, "https://github.com/login/oauth/authorize";
    is $site->site_access_token_uri, "https://github.com/login/oauth/access_token";
};

done_testing;
