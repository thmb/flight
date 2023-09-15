# TRANSFORM

docker pull ghcr.io/dbt-labs/dbt-core:1.5.0
docker pull ghcr.io/dbt-labs/dbt-postgres:1.5.0

docker run --rm -it -u $(id -u):$(id -g) -v $(pwd):/usr/src python:3.11 bash

pip install dbt-core dbt-postgres

docker run \
--network=host \
--mount type=bind,source=$(pwd),target=/usr/app \
--mount type=bind,source=$(pwd)/profiles.yml,target=/root/.dbt/profiles.yml \
ghcr.io/dbt-labs/dbt-postgres:1.5.0 \
debug
