#! /bin/bash

# prepare a trap to remove the port information from the open ports file
cleanup() {
    sed -i "/code-server ${USER}/d" "$DAT_FILE"
    exit
}
trap cleanup HUP INT TERM

# values that can be set using environmental variables

# name of the file that store the list of open ports for the project
DAT_FILE="${DAT_FILE:-"$HOME/singularity_open_ports.dat"}"
# number of port for the sshd service
CODESERVER_PORT="${CODESERVER_PORT:-"44000"}"

# the number of the port and the token with token are written to $DAT_FILE
echo "code-server ${USER} ${HOSTNAME}:${CODESERVER_PORT}" >> "$DAT_FILE"

# start code-server
code serve-web --port ${CODESERVER_PORT} --without-connection-token
