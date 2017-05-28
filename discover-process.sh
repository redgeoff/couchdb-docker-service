#!/bin/bash

# Wait until docker has finished setting up /etc/hosts
/wait-for-host.sh ${SERVICE_NAME}${TASK_SLOT}

docker-discover-tasks -s ${SERVICE_NAME} -p 3000 > /var/log/docker-discover-tasks.log
