#!/bin/bash

if [ "$#" -eq 0 ];
then

echo "Generates a unique OpenVPN configuration for a single player"
echo "Usage: $0 playername"

else

>$1-key.pem  openssl genrsa 2048
>$1-csr.pem  openssl req -new -key $1-key.pem -subj /CN=$1/
>$1-cert.pem openssl x509 -req -in $1-csr.pem -CA ca-cert.pem -CAkey ca-key.pem -days 365

source config.sh

>$1.conf cat <<EOF
client
nobind
dev tun
remote $SERVER_IP $PORT $PROTO
comp-lzo yes

<key>
$(cat $1-key.pem)
</key>
<cert>
$(cat $1-cert.pem)
</cert>
<ca>
$(cat ca-cert.pem)
</ca>
EOF

rm $1-{key,csr,cert}.pem

fi
