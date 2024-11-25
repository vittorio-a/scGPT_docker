#! /bin/bash

# prepare a trap to remove the port information from the open ports file
cleanup() {
    sed -i "/sshd ${USER}/d" "$DAT_FILE"
    exit
}
trap cleanup HUP INT TERM

# values that can be set using environmental variables

# name of the file that store the list of open ports for the project
DAT_FILE="${DAT_FILE:-"$HOME/singularity_open_ports.dat"}"
# number of port for the sshd service
SSH_PORT="${SSH_PORT:-"22222"}"
# path of the sshd configuration files
SSH_CONFIG_PATH="${SSH_CONFIG_PATH:-"$HOME/.sshd"}"

# save the port number in the open port user and home specific configuration file
# that will be read and given to the ssh client to find the random port
echo "sshd ${USER} ${HOSTNAME}:${SSH_PORT}" >> "$DAT_FILE"

# create certificates for openssh server
if [ ! -d "${SSH_CONFIG_PATH}" ]; then

    # create directory SSH_CONFIG_PATH
    mkdir "${SSH_CONFIG_PATH}"

    # generate keys and move them to SSH_CONFIG_PATH
    mkdir -p /tmp/etc/ssh
    ssh-keygen -A -f /tmp
    mv /tmp/etc/ssh/* "${SSH_CONFIG_PATH}"
    rm -fr /tmp/etc/

    # create ad hoc config file
    cat > "${SSH_CONFIG_PATH}/sshd_config" << EOF
# container-tailored configuration file
HostKey ${SSH_CONFIG_PATH}/ssh_host_rsa_key
HostKey ${SSH_CONFIG_PATH}/ssh_host_ecdsa_key
HostKey ${SSH_CONFIG_PATH}/ssh_host_ed25519_key
ChallengeResponseAuthentication no
UsePAM no
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem	sftp	/usr/lib/openssh/sftp-server
EOF
fi

# launch ssh daemon using port ${SSH_PORT}
/usr/sbin/sshd -D -p "${SSH_PORT}" -f "${SSH_CONFIG_PATH}/sshd_config"
