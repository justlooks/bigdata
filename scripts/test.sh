#!/bin/bash

count=2
skip=0

read_io() {
#cat /proc/diskstat
echo yes

}

while (($count>0));do
:<<'!'
!
if [ $skip -eq 0 ];then
	read_io
	if [ $count -gt 0 ];then
		((count--))
	fi
else
	skip=0
fi
done
