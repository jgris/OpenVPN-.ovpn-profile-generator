#!/bin/sh

##
## Usage: ./create-ovpn.sh USER_NAME PORT 
##
## Example invocation (note it must be run as root since key and cert files are protected
## ./create-ovpn.sh john 1194

# By default this script takes the IP address of current server as the address of VPN server.
server=`hostname -i`

user=${1?"User name is required"}
if [ ${2} ]
then
port=${2}
else
port=1194
fi


# By default all servers specified in *.conf files in the /etc/openvpn/ directory.
CONF_DIR=/etc/openvpn/

# Your directory with client's keys
KEYS=/etc/openvpn/easy-rsa/keys/

# Where to store the result file of this script. CONF_DIR by default.
RESULT_DIR=${CONF_DIR}

## Encryption cipher. Change if you need other.
server_cipher="aes-128-cbc"

cacert="${CONF_DIR}ca.crt"
client_cert="${KEYS}${user}.crt"
client_key="${KEYS}${user}.key"
tls_key="${CONF_DIR}ta.key"

# Check if the client exists, simply generate .ovpn file. 
# If the client does not exist, then generate the certificate, key and .ovpn for a new client.
if [ ! -e $client_cert ]
then
source ${CONF_DIR}easy-rsa/vars
${CONF_DIR}easy-rsa/build-key ${user}
fi

{
cat << EOF
${user}
tls-client
dev tun
remote ${server} ${port} udp
pull
redirect-gateway def1
resolv-retry infinite
nobind
persist-key
persist-tun
verb 3
tls-auth ta.key 1
cipher ${server_cipher}
auth SHA1
dhcp-option DNS 8.8.8.8
dhcp-option DNS 8.8.4.4
sndbuf 393216
rcvbuf 393216
resolv-retry infinite

<ca>
EOF
cat ${cacert}
cat << EOF
</ca>
<cert>
EOF
cat ${client_cert}
cat << EOF
</cert>
<key>
EOF
cat ${client_key}
cat << EOF
</key>
<tls-auth>
EOF
cat ${tls_key}
cat << EOF
</tls-auth>
EOF
} > "${RESULT_DIR}${user}.ovpn"

echo "Done! Your ovpn file here: ${RESULT_DIR}${user}.ovpn"
