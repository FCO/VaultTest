use Vault;
use Cro::HTTP::Log::File;
use Cro::HTTP::Server;
use Routes;

my Vault $vault;
with %*ENV<VAULT_DEV_ROOT_TOKEN_ID> {
    $vault = Vault.new(
        :token($_),
        |(:proto($_) with %*ENV<VAULT_PROTO>),
        |(:host($_)  with %*ENV<VAULT_HOST>),
        |(:port($_)  with %*ENV<VAULT_PORT>),
    ).new-acessor: :policies["web", "periodic"], :ttl(6);
    %*ENV<VAULT_DEV_ROOT_TOKEN_ID> = "";
}

my Cro::Service $http = Cro::HTTP::Server.new(
    http => <1.1>,
    host => %*ENV<VAULT_PERL6_HOST> ||
        die("Missing VAULT_PERL6_HOST in environment"),
    port => %*ENV<VAULT_PERL6_PORT> ||
        die("Missing VAULT_PERL6_PORT in environment"),
    application => routes(:$vault),
    after => [
        Cro::HTTP::Log::File.new(logs => $*OUT, errors => $*ERR)
    ]
);
$http.start;
say "Listening at http://%*ENV<VAULT_PERL6_HOST>:%*ENV<VAULT_PERL6_PORT>";
react {
    CATCH { default { .note }}
    whenever Supply.interval: 1 {
        say "going to renew";
        my $resp = await $vault.self-renew;
        done if $resp.code div 200 != 1;
        say "Token $vault.token() renewed"
    }
    whenever signal(SIGINT) {
        say "Shutting down...";
        $http.stop;
        done;
    }
}
