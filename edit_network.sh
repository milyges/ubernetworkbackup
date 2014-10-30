#!/bin/sh

START="10.0.0.10"
STOP="10.0.0.199"

UBDIR="$(dirname -- ${0})"

. "${UBDIR}/config.sh"
. "${UBDIR}/functions.sh"

START_A="$(echo "${START}" | cut -d'.' -f 1)"
START_B="$(echo "${START}" | cut -d'.' -f 2)"
START_C="$(echo "${START}" | cut -d'.' -f 3)"
START_D="$(echo "${START}" | cut -d'.' -f 4)"

STOP_A="$(echo "${STOP}" | cut -d'.' -f 1)"
STOP_B="$(echo "${STOP}" | cut -d'.' -f 2)"
STOP_C="$(echo "${STOP}" | cut -d'.' -f 3)"
STOP_D="$(echo "${STOP}" | cut -d'.' -f 4)"

for A in $(seq ${START_A} ${STOP_A})
do
	for B in $(seq ${START_B} ${STOP_B})
	do
		for C in $(seq ${START_C} ${STOP_C})
		do
			for D in $(seq ${START_D} ${STOP_D})
			do
				IP="${A}.${B}.${C}.${D}"
				# Sprawdzamy czy host zyje
				if ping -n -c1 "${IP}" > /dev/null 2>&1
				then
					echo "Host ${IP} alive!"
					${UBDIR}/editconfig.sh "${IP}"
				fi
			done
		done
	done
done
