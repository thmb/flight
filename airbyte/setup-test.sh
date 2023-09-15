#!/bin/bash

source ./utils/airbyte.sh


update_definition "./sources/mssql.json"

update_definition "./sources/salesforce.json"

update_definition "./destinations/redshift.json"

echo ""

fetch_workspace workspace_id

echo ""

create_definition "${workspace_id}" \
	"./connectors/source-sap-odata/definition.json" sap_odata_id

echo ""

create_operation "${workspace_id}" \
	"./connections/normalization.json" normalization_id

echo ""

create_source "${workspace_id}" "${inherit}" \
	"./sources/mes/mock.json" mes_id

create_source "${workspace_id}" "${inherit}" \
	"./sources/stor/mock.json" stor_id

create_source "${workspace_id}" "${inherit}" \
	"./sources/salesforce/sandbox.json" salesforce_id

create_source "${workspace_id}" "${sap_odata_id}" \
	"./sources/sap/quality.json" sap_id

echo ""

create_destination "${workspace_id}" "${inherit}" \
	"./destinations/redshift/test.json" redshift_id

echo ""

create_connection "${workspace_id}" "${mes_id}" "${redshift_id}" "${normalization_id}" \
	"./connections/production/mes.json"

create_connection "${workspace_id}" "${stor_id}" "${redshift_id}" "${normalization_id}" \
	"./connections/purchase/sap.json"
create_connection "${workspace_id}" "${stor_id}" "${redshift_id}" "${normalization_id}" \
	"./connections/purchase/stor.json"

create_connection "${workspace_id}" "${salesforce_id}" "${redshift_id}" "${normalization_id}" \
	"./connections/sales/salesforce.json"
create_connection "${workspace_id}" "${sap_id}" "${redshift_id}" "${normalization_id}" \
	"./connections/sales/sap.json"


exit 0 # success