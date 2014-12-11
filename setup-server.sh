#!/bin/bash
#
# Script to set up your RuCTFe router.
#
# Borrowed from https://github.com/tinfoil/openvpn_autoconfig
#
set -ex

source config.sh

read -p "Enter your team number: " TEAM

A=$((60 + TEAM / 256))
C=$((80 + TEAM / 256))
B=$((TEAM % 256))

apt-get update -qq
debconf-set-selections <<EOF
iptables-persistent iptables-persistent/autosave_v4 boolean true
iptables-persistent iptables-persistent/autosave_v6 boolean true
EOF
apt-get install -qqy openvpn curl iptables-persistent


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
>dh.pem     openssl dhparam 1024 

chmod 600 *-key.pem

# Set up IP forwarding and NAT for iptables
>>/etc/sysctl.conf echo net.ipv4.ip_forward=1
sysctl -p

iptables -A FORWARD -i team -o game -j ACCEPT
iptables -A FORWARD -o team -i game -j ACCEPT
>/etc/iptables/rules.v4 iptables-save

# Write configuration files for client and server
SERVER_IP=$(curl -s canhazip.com || echo "<insert server IP here>")

>server.conf cat <<EOF
topology    subnet
server      10.$A.$B.0 255.255.255.0
verb        3
keepalive   2 10
persist-key yes
persist-tun yes
comp-lzo    yes

client-config-dir clients

push "route 10.80.0.0 255.255.0.0 10.$A.$B.1"
push "route 10.60.0.0 255.255.0.0 10.$A.$B.1"

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

bash ./setup-client.sh pwnme

service openvpn restart

mkdir -p clients
>clients/pwnme cat <<EOF
ifconfig-push 10.$A.$B.100 10.$A.$B.1
EOF


if [[ $EUID -eq 0 ]]; then
  cp -ra server.conf clients /etc/openvpn
fi

