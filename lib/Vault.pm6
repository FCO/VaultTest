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
    $!http-client.get: "$!url/v2/$engine/$path"
}

method create-token(:@policies, :%metadata, Str :$ttl, Bool :$renewable) {
    say "CREATE: $!url/v1/auth/token/create";
    dd %(
        |(:@policies  if @policies ),
        |(:%metadata  if %metadata ),
        |(:$ttl       if $ttl      ),
        |(:$renewable if $renewable),
    );
    $!http-client.post:
        "$!url/v1/auth/token/create",
        :body(%(
            |(:@policies  if @policies ),
            |(:%metadata  if %metadata ),
            |(:$ttl       if $ttl      ),
            |(:$renewable if $renewable),
        ))
}

method new-acessor(|c) {
    say "new-acessor: {c}";
    my $resp  = await self.create-token(|c);
    say "aqui: ", $resp;
    my $json  = await $resp.body;
    say "aqui: ", $json;
    my $token = $json<auth><client_token>;
    self.new: :$token, :$!proto, :$!host, :$!port, :$!url;
}
