#!/bin/bash
rm /var/run/scriptstatus
echo "`date` status file removed, shutting down" >> /var/log/scriptlog
killall inotifywait
echo "`date` intoify stopped" >> /var/log/scriptlog

