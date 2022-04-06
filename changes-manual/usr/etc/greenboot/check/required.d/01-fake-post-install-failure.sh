#!/bin/sh
#

SCRIPT_NAME=$0

log() {
    echo "$*" | systemd-cat -t ${SCRIPT_NAME}
}

if [ -n "$(fw_printenv -n FAKE_POST_INSTALL_COMPLETE)" ]; then
    log "Fake post install has already forced a rollback.  Bypassing check"
    exit 0
fi

NUM_REBOOTS=$(fw_printenv -n bootcount)
NUM_REBOOTS=${NUM_REBOOTS:-1}
NUM_REBOOTS=$(expr $NUM_REBOOTS + 1)
log "Fake post install failure NUM_REBOOTS = " $NUM_REBOOTS

if [ "${NUM_REBOOTS}" -eq "4" ]; then
    # Now we will rollback
    # Make sure we only do this one time.
    log "Fake post install failure complete"
    fw_setenv FAKE_POST_INSTALL_COMPLETE 1
fi
exit -1
