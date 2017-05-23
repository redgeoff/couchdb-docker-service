#!/bin/bash

while [ true ]; do
  n=`grep $1 /etc/hosts | wc -l`
  if [ $n -ne 0 ]; then
    break;
  fi
  sleep 5
done
