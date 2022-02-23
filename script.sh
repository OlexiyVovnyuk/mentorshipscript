#!/bin/bash
echo "`date` starting up..." >> /var/log/scriptlog
. /home/kali/conf.conf
if [ -n $dir ] 
then
	echo "`date` conf read succesful, work directory is ${dir}" >> /var/log/scriptlog
else
	echo "`date` Error: invalid conf file" >> /var/log/scriptlog
	exit 8
fi
sleep 5
if [ -f /var/run/scriptstatus ]
then
	echo "`date` Error: found existing status file, please check whether script exited correctly last time" >> /var/log/scriptlog 
	exit 5 
else
	echo "`date` script is currently running in ${dir}" >> /var/run/scriptstatus 
	echo "`date` created status file in /var/run/scriptstatus" >> /var/log/scriptlog
fi
if [[ -d $dir ]];
then
	echo "`date` work directory exists, checking permissions..." >> /var/log/scriptlog
	if [ -r $dir ] && [ -w $dir ] && [ -x $dir ];
	then
		echo "`date` permissions are OK" >> /var/log/scriptlog
	else 
		echo "`date` Error: missing permission on workdir" >>  /var/log/scriptlog
		echo "`date` exiting" >> /var/log/scriptlog
		exit 3
	fi
else
	echo "`date` Error: workdir does no exist!" >> /var/log/scriptlog
	echo "`date` exiting" >> /var/log/scriptlog
	exit 4
fi
for subd in \
	"$dir/processed" \
	"$dir/archive" \
	"$dir/error"
do
	
	if [ -d $subd ]
	then
		echo "`date` ${subd} already exists, skipping" >> /var/log/scriptlog
	else
		mkdir $subd 
		echo "`date` ${subd} created" >> /var/log/scriptlog 
	fi
done
echo "`date` starting inotify..." >> /var/log/scriptlog
inotifywait -m -r -q -e close_write --format %f $dir |
	while read file; do
		if [[ "$file" =~ .*txt$ ]]; then
			mv "$dir/$file" $dir/processed
			echo "`date` $file has been processed" >> /var/log/scriptlog
		fi
	done & 
while true
do
 find $dir/processed -mmin -60 -type f -exec tar cvzf "{}.tar.gz" "{}" && mv "{}.tar.gz" $dir/archive && echo "`date` {} archived" \;
 sleep 60
done
