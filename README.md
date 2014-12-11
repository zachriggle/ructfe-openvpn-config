ructfe-openvpn-config
=====================

Auto-generates the necessary configuration for using OpenVPN to connect through your router for [RuCTFe][0].

It set up the OpenVPN server in a similar manner as the [Tinfoil VPN generator][1].

The only useful differences are the routes that it pushes down, and that it's set up for per-client configuration.

Additionally, this will generate a client-config for your pwnable server at `.100`.

Finally, it includes a tool for quickly generating configurations for teammates.

Configuration
---------

There are three knobs you may want to twiddle in `config.sh`.

If you don't run `setup-server.sh` on the actual server, you'll at least want to set the public IP in `config.sh`.

Usage
---------

Run `setup-server.sh` to generate the server keys and configuration.

If you run this as root, it'll also install the configuration files.

```sh
$ git clone https://github.com/zachriggle/ructfe-openvpn-config.git
$ cd ructfe-openvpn-config
$ bash setup-server.sh
...
Enter your team number: 129
...
Setup is complete.

Use generate-client-config.sh to generate keys for each team member.
Each machine connecting to the VPN must have a unique ID.

**ALTERNATELY** add a line containing 'duplicate-cn' to 'server.conf'.
This will allow different players to use the same key.

In either case, a special client key has been generated for the target
server.  It has been configured to use 10.60.129.100.
```

If you are not root:

```sh
$ cp -r clients server.conf /etc/openvpn/
$ service openvpn restart
```

By default, a client configuration for the game box is generated as `pwnme.conf`. 
On the game box...

```sh
$ cp pwnme.conf /etc/openvpn/
$ service openvpn restart
```

Finally, you'll want to generate configurations for each team member.
They should install the generated configuration in the same manner.  Alternately, the configurations are compatible with [Viscosity][2].

```sh
$ bash setup-client.sh ebeip90
$ ls | grep ebeip90
ebeip90.conf
```

[0]: ructf.org/e/2014/network
[1]: https://www.tinfoilsecurity.com/vpn/new
[2]: https://www.sparklabs.com/viscosity/
