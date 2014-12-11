ructfe-openvpn-config
=====================

Auto-generates the necessary configuration for using OpenVPN to connect through your router for [RuCTFe][0].

It set up the OpenVPN server in a similar manner as the [Tinfoil VPN generator][1].  The only useful differences are the routes that it pushes down, and that it's set up for per-client configuration.

Additionally, this will generate a client-config for your pwnable server at `.100`.

Finally, it includes a tool for quickly generating configurations for teammates.

A sample set of configuration files are included in `sample/`.

Configuration
---------

There are three knobs you may want to twiddle in `config.sh`.

If you don't run `setup-server.sh` on the actual VPN server, you'll at least want to set the public IP in `config.sh`.

Usage
---------

Run `setup-server.sh` to generate the server keys and configuration.

```sh
$ git clone https://github.com/zachriggle/ructfe-openvpn-config.git
$ cd ructfe-openvpn-config
$ bash setup-server.sh
...
Enter your team number: 129
...
```

This will generate some intermediary files, but the important ones are:

- VPN Server: `teamXX_server.conf` and `clients/`
- Game Box:   `teamXX_pwnme.conf`
- Teammates:  `teamXX_player.conf`

Install the files into `/etc/openvpn` on the appropriate machines.  You'll also want to put the config provided by RuCTFe as `game.conf` (or similar) on your VPN server.

[0]: http://ructf.org/e/2014/network
[1]: https://www.tinfoilsecurity.com/vpn/new
[2]: https://www.sparklabs.com/viscosity/
[3]: http://vpn.e.ructf.org
