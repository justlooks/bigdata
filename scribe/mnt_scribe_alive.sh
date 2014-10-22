#!/bin/bash

STATE_CRITICAL=2
STATE_WARNING=1
STATE_UNKNOWN=3
STATE_OK=0

DST="localhost 1463"


if nc -z -w1 ${DST};then
echo "scribed is alive"
exit $STATE_OK
else
echo "scribed is dead, check it!"
exit $STATE_CRITICAL
fi
