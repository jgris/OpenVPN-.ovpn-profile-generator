# OpenVPN *.ovpn profile generator
Simple and useful generator of OpenVPN client configuration file with embedded certificates. Also creates new client's cert and key if the client does not exist.

#Usage: ./create-ovpn.sh USER_NAME PORT
where USER_NAME is the name of client (creates new if don't exists) and PORT - is the port of your VPN server (1194 by default).
