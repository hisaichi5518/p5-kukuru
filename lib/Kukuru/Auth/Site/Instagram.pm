package Kukuru::Auth::Site::Instagram;
use Mouse;

extends 'Kukuru::Auth::Site::OAuth2';

has '+moniker' => (
    default => "instagram",
);

has '+site_authorize_uri' => (
    default => "https://api.instagram.com/oauth/authorize",
);

has '+site_access_token_uri' => (
    default => "https://api.instagram.com/oauth/access_token",
);

no Mouse;

1;
