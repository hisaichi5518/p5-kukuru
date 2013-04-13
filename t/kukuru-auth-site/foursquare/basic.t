use strict;
use warnings;
use Test::More;
use Kukuru::Auth::Site::Foursquare;

subtest 'new' => sub {
    my $site = Kukuru::Auth::Site::Foursquare->new(
        client_id     => "aaaaaaa",
        client_secret => "aaaaaaa",
    );

    is $site->moniker, "foursquare";
    is $site->site_authorize_uri, "https://foursquare.com/oauth2/authenticate";
    is $site->site_access_token_uri, "https://foursquare.com/oauth2/access_token";
};

done_testing;
