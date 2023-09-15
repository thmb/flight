# PIPELINE

## CMOC

docker run --name octavia -i --rm -v /opt/analytics/pipeline:/home/octavia-project --network host --user $(id -u):$(id -g) --env-file /opt/analytics/pipeline/.octavia.env airbyte/octavia-cli:0.42.1 apply

## LOCAL

docker run --name octavia -i --rm -v .:/home/octavia-project --network host --user $(id -u):$(id -g) --env-file .octavia.env airbyte/octavia-cli:0.42.1 apply

### Scafold

docker run -i --rm -v .:/home/octavia-project --network host --user $(id -u):$(id -g) --env-file .octavia.env airbyte/octavia-cli:0.42.1 generate source --help

docker run -i --rm -v .:/home/octavia-project --network host --user $(id -u):$(id -g) --env-file .octavia.env airbyte/octavia-cli:0.42.1 generate destination

docker run -i --rm -v .:/home/octavia-project --network host --user $(id -u):$(id -g) --env-file .octavia.env airbyte/octavia-cli:0.42.1 generate connection --source ./sources/mes/cmoc.yaml --destination ./destinations/mes/cmoc.yaml "MES (CMOC)"

docker run -i --rm -v .:/home/octavia-project --network host --user $(id -u):$(id -g) --env-file .octavia.env airbyte/octavia-cli:0.42.1 generate connection --source ./sources/stor/cmoc.yaml --destination ./destinations/stor/cmoc.yaml "Stor (CMOC)"


list workspace connections

octavia get connection <CONNECTION_ID> or <CONNECTION_NAME>