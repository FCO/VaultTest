use Cro::HTTP::Client;
unit class Vault;

has Str:D             $.token is required;
has Str               $.proto        = "http";
has Str               $.host         = "localhost";
has UInt              $.port         = 8200;
has Str               $.url          = "$!proto://$!host:$!port";
has Cro::HTTP::Client $.http-client .= new:
    :headers[
        :content-type<application/json>,
        X-Vault-Token => $!token
    ]
;

method secret(Str $path, Str :$engine = "secret") {
    my $resp = await $!http-client.get: "$!url/v1/$engine/data/$path";
    my $json = await $resp.body;
    $json<data>
}

method create-token(:@policies, :%metadata, Str :$ttl, Bool :$renewable) {
    $!http-client.post:
        "$!url/v1/auth/token/create",
        :body(%(
            |(:@policies  if @policies ),
            |(:%metadata  if %metadata ),
            |(:$ttl       if $ttl      ),
            |(:$renewable if $renewable),
        ))
}

method self-renew(Str :$increment) {
    $!http-client.post:
        "$!url/v1/auth/token/renew-self",
        :body(%(
            |(:$increment if $increment),
        ))
}

method new-acessor(|c) {
    my $resp  = await self.create-token(|c);
    die await $resp.body if $resp.code div 200 != 1;
    my $json  = await $resp.body;
    my $token = $json<auth><client_token>;
    self.new: :$token, :$!proto, :$!host, :$!port, :$!url;
}
