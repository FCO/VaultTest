use Vault;
use Cro::HTTP::Router;

sub routes(Vault :$vault) is export {
    route {
        get -> {
            my $resp = await $vault.secret: 'web/password';
            my $json = await $resp.body;
            content 'text/html', "<h1> Secret: { $json<pepper> } </h1>";
        }
    }
}
