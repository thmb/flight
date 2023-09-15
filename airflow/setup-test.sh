#!/bin/bash

source ./utils/airflow.sh


variables="./config/variables/test.json"

keys=( $(cat "$variables" | jq -r '. | keys[]') )

for key in "${keys[@]}"
do
    value="$(jq -r ".$key" $variables)"
    create_variable "$key" "$value"
done

create_connection "./config/connections/airbyte/test.json"

create_connection "./config/connections/ssh/test.json"


exit 0 # success