package Kukuru::Auth::Site::Foursquare;
use Mouse;

extends 'Kukuru::Auth::Site::OAuth2';

has '+moniker' => (
    is => 'rw',
    default => "foursquare",
);

has '+site_authorize_uri' => (
    is => 'rw',
    default => "https://foursquare.com/oauth2/authenticate",
);

has '+site_access_token_uri' => (
    is => 'rw',
    default => "https://foursquare.com/oauth2/access_token",
);

1;
