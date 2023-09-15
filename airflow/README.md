# WORKFLOW

airflow connections add 'ssh' --conn-uri 'ssh://thiago:8462@airbyte-proxy:22'

airflow connections add 'ssh' --conn-type 'SSH' --conn-login 'thiago' --conn-password '8462' --conn-host 'airbyte-proxy' --conn-port '22'


airflow connections add 'airbyte' --conn-uri 'airbyte://airbyte:airbyte@airbyte-proxy:8000'

airflow connections add 'airbyte' --conn-type 'Airbyte' --conn-login 'airbyte' --conn-password 'airbyte' --conn-host 'airbyte-proxy' --conn-port '8000'

