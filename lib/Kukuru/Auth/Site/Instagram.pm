package Kukuru::Auth::Site::Instagram;
use Mouse;

extends 'Kukuru::Auth::Site::OAuth2';

has '+moniker' => (
    is => 'rw',
    default => "instagram",
);

has '+site_authorize_uri' => (
    is => 'rw',
    default => "https://api.instagram.com/oauth/authorize/",
);

has '+site_access_token_uri' => (
    is => 'rw',
    default => "https://api.instagram.com/oauth/access_token",
);

no Mouse;

1;
