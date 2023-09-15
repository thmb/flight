{{ config( materialized = 'table' ) }}

with sap_data as (
    SELECT
        id as sap_id
        ,salesorder
        ,soldtoparty -- cliente
        ,convert(float, sddocumentcollectivenumber) as sddocumentcollectivenumber -- chave externa no salesforce
        ,referencesddocument -- codigo da cotacao no sap (vindo do salesforce)
        ,totalnetamount
        ,transactioncurrency
    FROM
        stage.sap_sales_order_results
),

salesforce_data as (
    SELECT
        id as salesforce_id
        ,name
        ,convert(float, chave_externa__c) as  chave_externa__c-- sddocumentcollectivenumber
        ,nro_cotacao_sap__c
        ,nro_pedido__c
        ,chave_externa_origem__c
    FROM
        stage.salesforce_opportunity
),

final as (
    select
        *
    from
        sap_data
    inner join
        salesforce_data on sap_data.sddocumentcollectivenumber = salesforce_data.chave_externa__c
)

select * from final
