#!/bin/bash

function title {
	echo "=================================================="
	echo " ${1}"
	echo "=================================================="
}

title "PIPELINE" # start pipeline containers in detached mode
docker compose --file ./pipeline/docker-compose.yaml up --detach

title "WORKFLOW" # build and start workflow containers in detached mode (flower optional)
docker compose --file ./workflow/docker-compose.yaml build
docker compose --file ./workflow/docker-compose.yaml \
	--file ./workflow/docker-network.yaml up --detach # --profile flower

title "WAREHOUSE" # start warehouse containers in detached mode
docker compose --file ./warehouse/docker-compose.yaml \
	--file ./warehouse/docker-network.yaml up --detach

# title "MOCKUP" # start mockup containers in detached mode
# docker compose --file ./mockup/docker-compose.yaml up --detach # --profile admin