#!/bin/sh

if [ -z "${1}" ]
then
        echo "Usage: $0 host"
        exit 1
fi

UBDIR="$(dirname -- ${0})"

. "${UBDIR}/config.sh"
. "${UBDIR}/functions.sh"

IP="${1}"

${SSH} -t ${SSH_OPTS} "${SSH_USER}@${1}" "sudo nano /etc/uberbackup.conf"
