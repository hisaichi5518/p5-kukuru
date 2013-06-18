package Kukuru::Auth::Site::Foursquare;
use Mouse;

extends 'Kukuru::Auth::Site::OAuth2';

has '+moniker' => (
    default => "foursquare",
);

has '+site_authorize_uri' => (
    default => "https://foursquare.com/oauth2/authenticate",
);

has '+site_access_token_uri' => (
    default => "https://foursquare.com/oauth2/access_token",
);

no Mouse;

1;
