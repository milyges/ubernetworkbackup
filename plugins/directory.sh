#!/bin/sh

backup_directory() {
	DIR="$(job_get_param "${CONFIG}" "${JOB}" "directory" | sed -e 's#\(.\+\)/$#\1#g')"
	EXCLUDES="$(job_get_param "${CONFIG}" "${JOB}" "exclude" | awk '{ print "--exclude \"" $0 "\"" }' | tr '\n' ' ')"
	DESTDIR="$(get_backup_dir ${HOST})/directory$(dirname "${DIR}")"

	mkdir -p "${DESTDIR}"

	echo "Backing up directory ${DIR} on ${HOST} to ${DESTDIR}" | log
	${RSYNC} -ar --delete --numeric-ids -e "ssh ${SSH_OPTS}" --rsync-path="sudo rsync ${EXCLUDES}" ${EXCLUDES} "${SSH_USER}@${IP}:${DIR}" "${DESTDIR}" 2>&1  | log

	return 0
}
