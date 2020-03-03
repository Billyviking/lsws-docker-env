#!/bin/bash
LSDIR='/usr/local/lsws'

help_message(){
    echo 'Command [-serial|-S] SERIAL'
    echo 'Example: serialctl.sh -s SERIAL'
    echo 'Example: serialctl.sh -s TRIAL'
	exit 0
}

check_input(){
    if [ -z "${1}" ]; then
        help_message
        exit 1
    fi
}

backup_old(){
    if [ -f ${1} ] && [ ! -f ${1}_old ]; then
       mv ${1} ${1}_old
    fi
}

apply_serial(){
    check_input ${1}
    echo ${1} | grep -i 'trial' >/dev/null
    if [ ${?} = 0 ]; then 
        echo 'Apply Trial License'
        if [ ! -e ${LSDIR}/conf/serial.no ] && [ ! -e ${LSDIR}/conf/license.key ]; then
            rm -f ${LSDIR}/conf/trial.key*
            wget -P ${LSDIR}/conf -q http://license.litespeedtech.com/reseller/trial.key
            echo 'Apply trial finished'
        else
            echo "Please backup and remove your existing license, apply abort!"
            exit 1    
        fi
    else
        echo "Apply Serial number: ${1}"
        backup_old ${LSDIR}/conf/serial.no
        backup_old ${LSDIR}/conf/license.key
        backup_old ${LSDIR}/conf/trial.key
        echo "${1}" > ${LSDIR}/conf/serial.no
        ${LSDIR}/bin/lshttpd -r
        if [ -f ${LSDIR}/conf/license.key ]; then
            echo '[O] Apply success'
        else 
            echo '[X] Apply failed, please check!'
            exit 1
        fi
    fi
}

check_input ${1}
while [ ! -z "${1}" ]; do
    case ${1} in
        -[hH] | -help | --help)
            help_message
            ;;
        -[sS] | -serial) shift
            apply_serial "${1}"
            ;;            
        *)
            help_message
            ;;
    esac
    shift
done