#!/bin/bash

docker-discover-tasks -s $SERVICE_NAME -p 3000 > /var/log/docker-discover-tasks.log
