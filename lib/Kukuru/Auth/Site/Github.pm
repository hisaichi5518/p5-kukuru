package Kukuru::Auth::Site::Github;
use Mouse;

extends 'Kukuru::Auth::Site::OAuth2';

has '+moniker' => (
    default => "github",
);

has '+site_authorize_uri' => (
    default => "https://github.com/login/oauth/authorize",
);

has '+site_access_token_uri' => (
    default => "https://github.com/login/oauth/access_token",
);

no Mouse;

1;
