use Vault;
use Cro::HTTP::Router;

sub routes(Vault :$vault!, UInt :$wait! is rw) is export {
    route {
        get -> {
            content 'text/html', "<h1> Secret: </h1><pre>{ $vault.secret('web/password')<data> } </pre>";
        }

        get -> "wait", UInt $rn = 0 {
            $wait = $rn;
            content 'text/html', "<h1> Waiting for $wait </h1>";
        }
    }
}
