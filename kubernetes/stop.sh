#!/bin/bash

function title {
	echo "=================================================="
	echo " ${1}"
	echo "=================================================="
}

title "WAREHOUSE" # stop warehouse containers and remove their volumes
docker compose --file warehouse/docker-compose.yaml \
	--file warehouse/docker-network.yaml down --volumes

title "WORKFLOW" # stop workflow containers and remove their volumes
docker compose --file workflow/docker-compose.yaml \
	--file workflow/docker-network.yaml down --volumes
# docker stop workflow-flower-1 && docker rm workflow-flower-1

title "PIPELINE" # stop pipeline containers and remove their volumes
docker compose --file pipeline/docker-compose.yaml down --volumes

# title "MOCKUP" # stop mockup containers and remove their volumes
# docker compose --file mockup/docker-compose.yaml down --volumes

# OPTIONAL

docker stop $(docker ps --all --quiet --filter "name=buildkit")

docker rm $(docker ps --all --quiet --filter "name=buildkit")

docker volume rm $(docker volume ls -q) # remove all unused volumes

# docker network prune --force # prune all non-default networks
