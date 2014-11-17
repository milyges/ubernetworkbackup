#!/bin/sh

if [ -z "${1}" ]
then
	echo "Usage: $0 host1 host2 ..."
	exit 1
fi

UBDIR="$(dirname -- ${0})"

. "${UBDIR}/config.sh"
. "${UBDIR}/functions.sh"

while [ -n "${1}" ]
do
	IP="${1}"
	echo "Starting backup on host ${IP}" | log
	HOST="$(get_remote_hostname ${IP})"
	if [ -z "${HOST}" ]
	then
		echo "Error getting remote host name, exiting..." | log
		shift
		continue
	fi


	echo "Remote hostname is ${HOST}, getting config file." | log
	CONFIG=$(mktemp)
	get_config_file "${IP}" > "${CONFIG}"

	echo "Rotating backup directory..." | log
	rotate_dir "$(get_host_dir ${HOST})" "${KEEP}" "$(get_backup_dir "${HOST}")"

	# Pobieramy liste zadan
	for JOB in $(awk -F '.' '$1 == "job" { print $2 }' "${CONFIG}" | sort | uniq)
	do
		echo "Starting job ${JOB} on ${HOST}" | log
		TYPE="$(grep "job.${JOB}.type" "${CONFIG}" | awk -F'=' '{ print $2 }' |  sed 's/^[ \t]*//;s/[ \t]*$//')"
		backup_${TYPE}
	done

	rm -f "${CONFIG}"
	echo "All jobs on ${HOST} completed" | log
	shift
done

