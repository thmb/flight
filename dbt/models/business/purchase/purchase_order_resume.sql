{{ config( materialized = 'table' ) }}

with sap_data as (
    SELECT
        purchaseorder
        ,purchaseordertype
        ,purchaseordersubtype 
        ,supplier
        ,documentcurrency
        ,PurgReleaseTimeTotalAmount
    FROM
        stage.sap_purchase_order_results
),

stor_data as (
    SELECT
        id_erp_order_item
        ,order_number
        ,order_item -- consulta sap nao tem os itens?
        ,id_project
        ,partner_code
        ,contract_number
        ,order_price
        ,por
        ,id_item
        ,item_description
    FROM
        stage.stor_erp_order_item
),

final as (
    select
        *
    from
        sap_data
    inner join
        stor_data on sap_data.purchaseorder = stor_data.order_number
)

select * from final
