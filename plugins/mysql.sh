#!/bin/sh

backup_mysql() {
	USER="$(job_get_param "${CONFIG}" "${JOB}" "user")"
	PASSWD="$(job_get_param "${CONFIG}" "${JOB}" "password")"
	DBS="$(job_get_param "${CONFIG}" "${JOB}" "databases")"
	DESTDIR="$(get_backup_dir ${HOST})/mysql"

	mkdir -p "${DESTDIR}"

	if [ "${DBS}" = "*" ]
	then
		# Pobieramy liste baz danych
		DBS=$(${SSH} ${SSH_OPTS} "${SSH_USER}@${IP}" "echo 'SHOW DATABASES;' | mysql --user=${USER} --password=${PASSWD} -s")
	fi

	for DB in ${DBS}
	do
		if [ "$DB" = "mysql" ] || [ $DB = "information_schema" ] || [ "${DB}" = "performance_schema" ]
		then
			continue
		fi

		echo "Backing up MySQL database ${DB}" | log
		DUMPLOG=$(mktemp)
		rm -f "${DESTDIR}/${DB}.sql.gz"
		${SSH} ${SSH_OPTS} "${SSH_USER}@${IP}" "mysqldump --user=${USER} --password=${PASSWD} ${DB}" 2>> "${DUMPLOG}" | gzip -c > "${DESTDIR}/${DB}.sql.gz" 2>> "${DUMPLOG}"
		[ -s "${DUMPLOG}" ] && cat "${DUMPLOG}" | log
		rm -f "${DUMPLOG}"
	done

	return 0
}
