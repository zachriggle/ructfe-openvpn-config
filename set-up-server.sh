#!/bin/bash
#
# Script to set up your RuCTFe router.
#
# Borrowed from https://github.com/tinfoil/openvpn_autoconfig
#
set -e

source config.sh

read -p "Enter your team number: " TEAM

A=10
B=$((60 + TEAM / 256))
C=$((TEAM % 256))

if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user" 1>&2
  exit 1
fi

apt-get update -q
debconf-set-selections <<EOF
iptables-persistent iptables-persistent/autosave_v4 boolean true
iptables-persistent iptables-persistent/autosave_v6 boolean true
EOF
apt-get install -qy openvpn curl iptables-persistent

# Certificate Authority
>ca-key.pem      openssl genrsa 2048
>ca-csr.pem      openssl req -new -key ca-key.pem -subj /CN=ca/
>ca-cert.pem     openssl x509 -req -in ca-csr.pem -signkey ca-key.pem -days 365
>ca-cert.srl     echo 01

# Server Key & Certificate
>server-key.pem  openssl genrsa 2048
>server-csr.pem  openssl req -new -key server-key.pem -subj /CN=server/
>server-cert.pem openssl x509 -req -in server-csr.pem -CA ca-cert.pem -CAkey ca-key.pem -days 365

# Diffie hellman parameters
>dh.pem     openssl dhparam 2048

chmod 600 *-key.pem

# Set up IP forwarding and NAT for iptables
>>/etc/sysctl.conf echo net.ipv4.ip_forward=1
sysctl -p

iptables -A FORWARD -i team -o game -j ACCEPT
iptables -A FORWARD -o team -i game -j ACCEPT
>/etc/iptables/rules.v4 iptables-save

# Write configuration files for client and server
SERVER_IP=$(curl -s canhazip.com || echo "<insert server IP here>")

>team.conf cat <<EOF
topology    subnet
server      $A.$B.$C.0 255.255.255.0
verb        3
keepalive   2 10
persist-key yes
persist-tun yes
comp-lzo    yes

client-config-dir clients

user        nobody
group       nogroup
proto       $PROTO
port        $PORT
dev         team
dev-type    tun
status      status.log

<key>
$(cat server-key.pem)
</key>
<cert>
$(cat server-cert.pem)
</cert>
<ca>
$(cat ca-cert.pem)
</ca>
<dh>
$(cat dh.pem)
</dh>
EOF

bash ./setup-player.sh pwnme

service openvpn restart

mkdir clients
>clients/pwnme cat <<EOF
ifconfig-push $A.$B.$C.100 $A.$B.$C.1
EOF

cp -ra server.conf clients /etc/openvpn

cat <<EOF
Setup is complete.

Use generate-client-config.sh to generate keys for each team member.
Each machine connecting to the VPN must have a unique ID.

**ALTERNATELY** add a line containing 'duplicate-cn' to 'server.conf'.
This will allow different players to use the same key.

In either case, a special client key has been generated for the target
server.  It has been configured to use $A.$B.$C.100.
EOF

