use Vault;
use Cro::HTTP::Router;

sub routes(Vault :$vault!, Bool :$renew! is rw) is export {
    route {
        get -> {
            content 'text/html', qq:to/EOH/;
                <table>
                    <tr>
                        <th align=right>Renew:</th>
                        <td align=left>
                            {
                                $renew
                                    ?? qq:to/END/
                                        Running
                                        <button onclick="window.location='/renew/pause'">&#9616;&#9616;</button>
                                    END
                                    !! qq:to/END/
                                        Paused
                                        <button onclick="window.location='/renew/resume'">&#9658;</button>
                                    END
                            }
                        </td>
                    </tr>
                    <tr>
                        <th align=right>Token:</th>
                        <td align=left>
                            {
                                $vault.token
                            }
                        </td>
                    </tr>
                    <tr>
                        <th align=right>Root Token:</th>
                        <td align=left>
                            {
                                %*ENV<VAULT_DEV_ROOT_TOKEN_ID>
                            }
                        </td>
                    </tr>
                    <tr align=right>
                        <th>Last Update:</th>
                        <td align=left id=last_update>
                        </td>
                    </tr>
                    <tr align=right>
                        <th>Secret:</th>
                        <td align=left id=pepper>
                            {
                                $vault.secret('web/password')<data><pepper>
                            }
                        </td>
                    </tr>
                </table>
                <script>
                    async function getPepper\() \{
                        let resp = await fetch("/secret");
                        let data = await resp.json();

                        document.querySelector\("td#last_update").innerText = data.last_update;
                        document.querySelector\("td#pepper").innerText      = data.pepper;
                    \}

                    setInterval\(getPepper, 1000);
                </script>
            EOH
        }

        get -> "secret" {
            content "application/json", %(
                last_update => DateTime.now.hh-mm-ss,
                |$vault.secret('web/password')<data>,
            )
        }

        get -> "renew", "resume" {
            $renew = True;
            redirect "/"
        }

        get -> "renew", "pause" {
            $renew = False;
            redirect "/"
        }
    }
}
