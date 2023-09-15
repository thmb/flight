from __future__ import annotations

from airflow import DAG
from airflow.providers.airbyte.operators.airbyte import AirbyteTriggerSyncOperator
from airflow.providers.ssh.operators.ssh import SSHOperator

from utils import airflow, airbyte, dbt


dag = DAG(
    dag_id="Production",
    description="Take snapshot, syncronize stage, run business logic and compile features",
    default_args=airflow.default_dag_args,
    tags=["MES"],
    catchup=False,
)

snapshot = SSHOperator(
    task_id="snapshot",
    ssh_conn_id="transform",
    command=dbt.snapshot(""), # no selection
    cmd_timeout=600,  # 10 minutes
    dag=dag,
)

stage = AirbyteTriggerSyncOperator(
    task_id="stage",
    airbyte_conn_id="pipeline",
    connection_id=airbyte.connection(feature="Production", source="MES"),
    dag=dag,
)

business = SSHOperator(
    task_id="business",
    ssh_conn_id="transform",
    command=dbt.run(""), # no selection
    cmd_timeout=600,  # 10 minutes
    dag=dag,
)

feature = SSHOperator(
    task_id="feature",
    ssh_conn_id="transform",
    command=dbt.run(""), # no selection
    cmd_timeout=600,  # 10 minutes
    dag=dag,
)

snapshot >> stage >> business >> feature
