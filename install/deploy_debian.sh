#!/bin/sh

if [ -z "${1}" ]
then
	echo "Usage: $0 host"
	exit 1
fi

UBDIR="$(dirname -- ${0})/../"

. "${UBDIR}/config.sh"
. "${UBDIR}/functions.sh"

PUBKEY="$(cat "${SSH_KEY}.pub")"

CMD="useradd -r -d /var/lib/${SSH_USER} -m -N -g users -s /bin/bash ${SSH_USER} && mkdir /var/lib/${SSH_USER}/.ssh && chmod 0700 /var/lib/${SSH_USER}/.ssh && chown ${SSH_USER}:users /var/lib/${SSH_USER}/.ssh"
CMD="${CMD} && echo '${PUBKEY}' > /var/lib/${SSH_USER}/.ssh/authorized_keys && aptitude update && aptitude -y install rsync sudo"
CMD="${CMD} && echo '${SSH_USER}     ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"

echo "Deploying on ${1}"
ssh -t "root@${1}" "${CMD}"
