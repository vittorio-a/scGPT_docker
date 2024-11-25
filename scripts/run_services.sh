#! /bin/bash

# function to generate an unoccupied random port number
random_port() {
    TMP_FILE1=$(mktemp --tmpdir=$HOME)
    TMP_FILE2=$(mktemp --tmpdir=$HOME)
    seq "20000" "30000" | sort > ${TMP_FILE1}
    ss -tan | awk '{print $4}' | cut -d':' -f2 | grep '[0-9]\{1,5\}' | sort -u > ${TMP_FILE2}
    PORT_NUMBER=$(comm -23 ${TMP_FILE1} ${TMP_FILE2} | shuf | head -n "1")
    rm ${TMP_FILE1} ${TMP_FILE2}
}

# values that can be set using environmental variables
JUPYTERLAB="${JUPYTERLAB:-"false"}"
RSTUDIOSERVER="${RSTUDIOSERVER:-"false"}"
CODESERVER="${CODESERVER:-"false"}"

######################################################################################################
#                                          SSH
######################################################################################################

# generate random number for the ssh port, unless the variable is already defined
random_port; SSH_PORT="${SSH_PORT:-${PORT_NUMBER}}"

# launch sshd
run_sshd.sh > /dev/null &

######################################################################################################
#                                      JUPYTER LAB
######################################################################################################

# generate random number for the jupyter lab port, unless the variable is already defined
random_port; JUPYTER_PORT="${JUPYTER_PORT:-${PORT_NUMBER}}"

# launch jupyter lab
if [[ ${JUPYTERLAB} == "true" ]]; then
    run_jupyterlab.sh  > /dev/null &
fi

######################################################################################################
#                                    RSTUDIO SERVER
######################################################################################################

# generate random number for the rstudio-server port, unless the variable is already defined
random_port; RSERVER_PORT="${RSERVER_PORT:-${PORT_NUMBER}}"

# launch rstudio-server
if [[ ${RSTUDIOSERVER} == "true" ]]; then
    run_rstudioserver.sh > /dev/null &
fi

######################################################################################################
#                                     CODE SERVER
######################################################################################################

# generate random number for the code-server port, unless the variable is already defined
random_port; CODESERVER_PORT="${CODESERVER_PORT:-${PORT_NUMBER}}"

# launch code-server
if [[ ${CODESERVER} == "true" ]]; then
    run_codeserver.sh > /dev/null &
fi

# print info on open ports to screen
cat $HOME/singularity_open_ports.dat