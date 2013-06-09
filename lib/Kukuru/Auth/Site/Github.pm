package Kukuru::Auth::Site::Github;
use Mouse;

extends 'Kukuru::Auth::Site::OAuth2';

has '+moniker' => (
    is => 'rw',
    default => "github",
);

has '+site_authorize_uri' => (
    is => 'rw',
    default => "https://github.com/login/oauth/authorize",
);

has '+site_access_token_uri' => (
    is => 'rw',
    default => "https://github.com/login/oauth/access_token",
);

no Mouse;

1;
