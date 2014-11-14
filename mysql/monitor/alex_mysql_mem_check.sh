#!/bin/bash

while true
do
  date >> ps.log
  ps aux | grep mysqld >> ps.log
  sleep 60
done
