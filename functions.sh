
SSH="$(which ssh)"
SSH_OPTS="-o PasswordAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=error -i ${SSH_KEY}"

IONICE="$(which ionice) -c 2 -n 7"
RSYNC="$(which rsync)"
LOGFILE="/tmp/uberbackup.log"
PIDSFILE="/run/uberbackup.pids"

get_remote_hostname() {
	${SSH} ${SSH_OPTS} "${SSH_USER}@${1}" "hostname" 2> /dev/null
	return $?
}

get_remote_users() {
	${SSH} ${SSH_OPTS} "${SSH_USER}@${1}" "who -q" 2> /dev/null | head -n 1
	return $?
}

get_config_file() {
	${SSH} ${SSH_OPTS} "${SSH_USER}@${1}" "sudo cat /etc/uberbackup.conf" 2>/dev/null | grep -v '^#' | grep -v '^$'
	return $?
}

get_host_dir() {
	echo "${BACKUP_DIR}/${1}"
}

get_backup_dir() {
	echo "${BACKUP_DIR}/${1}/$(date "+${NAME_FORMAT}")"
}

# katalog ilosc_kopii nowy_katalog
rotate_dir() {
	[ -e "${3}" ] && return 0

	# Usuwamy stare kopie
	ls -1t "${1}" 2> /dev/null | awk "NR > ${2} { print \$0 }" | while read NAME
	do
		echo rm -rf "${1}/${NAME}"
	done

	# Sprawdzamy czy damy rade wykorzystac stara kopie do nałożenia nowych plików
	OLD_BACKUP="$(ls -1t "${1}" 2>/dev/null | awk "NR == ${2} { print \$0 }")"

	if [ -z "${OLD_BACKUP}" ]
	then
		OLD_BACKUP="$(ls -1t "${1}" 2> /dev/null | head -n 1)"
		[ -z "${OLD_BACKUP}" ] && mkdir -p "${3}" || cp -al "${1}/${OLD_BACKUP}" "${3}" | log
	else
		mv "${1}/${OLD_BACKUP}" "${3}" | log
	fi

	touch "${3}"
}

log() {
	while read LINE
	do
		NOW=$(date '+%H:%M %d-%m-%Y')
		[ -z "${MAILTO}" ] && echo "${NOW}: ${LINE}" || echo "${NOW}: ${LINE}" >> "${LOGFILE}"
	done
}

job_get_param() {
	grep "job.${2}.${3}" "${1}" | awk -F'=' '{ print $2 }' |  sed 's/^[ \t]*//;s/[ \t]*$//'
}

startup() {
	echo "$$" >> "${PIDSFILE}"
	touch "${LOGFILE}"
}

cleanup() {
	sed -i -e "/$$/d" "${PIDSFILE}"
	if [ ! -s "${PIDSFILE}" ]
	then
		if [ -n "${MAILTO}" ] && [ "${DISABLE_MAIL}" != "true" ]
		then
			mail -s "UberBackup on $(hostname --fqdn) report" "${MAILTO}" < "${LOGFILE}"
		fi
		rm -f "${PIDSFILE}"
		rm -f "${LOGFILE}"
	fi
}

# Ładowanie pluginow
for PLUGIN in ${UBDIR}/plugins/*.sh
do
	. "${PLUGIN}"
done

trap cleanup EXIT

startup
