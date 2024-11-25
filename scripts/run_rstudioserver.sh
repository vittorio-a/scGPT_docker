#! /bin/bash

# prepare a trap to remove the port information from the open ports file
cleanup() {
    sed -i "/rstudio-server ${USER}/d" "$DAT_FILE"
    exit
}
trap cleanup HUP INT TERM

# values that can be set using environmental variables

# name of the file that store the list of open ports for the project
DAT_FILE="${DAT_FILE:-"$HOME/singularity_open_ports.dat"}"
# number of port for the sshd service
RSERVER_PORT="${RSERVER_PORT:-"8787"}"
# working files of rstudio-server
COOKIE_FILE="${COOKIE_FILE:-"$HOME/.rserver-${USER}/secure-cookie-key"}"

# start RStudio-Server in background, the number of the port is written to the $DAT_FILE file
echo "rstudio-server ${USER} ${HOSTNAME}:${RSERVER_PORT}" >> "$DAT_FILE"

# start rstudio-server
/usr/lib/rstudio-server/bin/rserver --server-daemonize=0 \
                                    --secure-cookie-key-file "${COOKIE_FILE}" \
                                    --www-port "${RSERVER_PORT}" \
                                    --server-user "${USER}"
