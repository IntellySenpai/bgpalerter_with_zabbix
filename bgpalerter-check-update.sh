#!/usr/bin/env bash

# SPECIFY DIRECTORIES FOR BINARY AND LOGS
DIR=/home/bgpalerter
LOGS=$DIR/logs

# IF STATUS.LOG DOESN'T EXIST, CREATE IT
if [ ! -f $LOGS/status.log ]; then
  touch $LOGS/status.log
  chown bgpalerter:bgpalerter $LOGS/status.log
fi

# REMOVE STATUS.LOG IF BIGGER THAN 5MB
find $LOGS -type f -name "status.log" -size +5M -delete

exec >> $LOGS/status.log 2>&1

cd $DIR

# DOWNLOAD LAST LATEST VERSION AND STORE IT AS TEMPORARY
wget --no-verbose -O bgpalerter-linux-x64.tmp https://github.com/nttgin/BGPalerter/releases/latest/download/bgpalerter-linux-x64

# GIVE EXEC PERMISSIONS TO FILE
chmod +x bgpalerter-linux-x64.tmp

# SET VARIABLES TO COMPARE VERSIONS
if [ -f bgpalerter-linux-x64 ]; then
  v1=$(./bgpalerter-linux-x64 -v)
  v2=$(./bgpalerter-linux-x64.tmp -v)

else
  v1=$"0"
  v2=$(./bgpalerter-linux-x64.tmp -v)
fi

# IF CURRENT VERSION NOT FOUND
if [ "$v1" == "0" ];then
  #Remove the file
  rm bgpalerter-linux-x64.tmp

  echo "$(date '+%Y-%m-%dT%H:%M:%S') update: BGPalerter Error. Tryed to find update. However, $DIR/bgpalerter-linux-x64 cannot be found."
  exit 1

# NEW VERSION FOUND
elif [ "$v1" != "$v2" ];then
  echo "$(date '+%Y-%m-%dT%H:%M:%S') update: BGPalerter New Version. A new version of BGPalerter has been found. Previous version $v1. New version available $v2."

else
  # IF VERSIONS THE SAME DELETE TEMPORARY FILE
  rm bgpalerter-linux-x64.tmp
  echo "$(date '+%Y-%m-%dT%H:%M:%S') update: BGPalerter Up To Date. Current version $v1."
fi

