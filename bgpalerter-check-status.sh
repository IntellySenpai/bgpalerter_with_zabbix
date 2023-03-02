#!/usr/bin/env bash

# SPECIFY DIRECTORIES FOR BINARY AND LOGS
DIR=/home/bgpalerter
LOGS=$DIR/logs

# IF UPGRADE.LOG DOESN'T EXIST, CREATE IT
if [ ! -f $LOGS/status.log ]; then
  touch $LOGS/status.log
  chown bgpalerter:bgpalerter $LOGS/status.log
fi

# REMOVE STATUS.LOG IF BIGGER THAN 5MB
find $LOGS -type f -name "status.log" -size +5M -delete

exec >> $LOGS/status.log 2>&1

cd $DIR


# CHECK THE STATUS
service=bgpalerter.service

STATUS="$(systemctl is-active $service)"
RUNNING="$(systemctl show -p SubState $service | cut -d'=' -f2)"
echo "$(date '+%Y-%m-%dT%H:%M:%S') status: $service is ${STATUS} and ${RUNNING}"
