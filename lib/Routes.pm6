use Vault;
use Cro::HTTP::Router;

sub routes(Vault :$vault) is export {
    route {
        get -> {
            content 'text/html', "<h1> Secret: </h1><pre>{ $vault.secret('web/password')<data> } </pre>";
        }
    }
}
