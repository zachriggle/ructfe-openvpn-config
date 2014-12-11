#!/bin/sh

#
# If you don't want to use TCP port 443, change it here.
#
export PROTO=tcp
export PORT=443

#
# Set your OpenVPN server's IP address here
#
export SERVER_IP=$(curl -s canhazip.com || echo "<insert server IP here>")

