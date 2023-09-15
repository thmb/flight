from abc import ABC
from datetime import datetime, timedelta, time
from dateutil.relativedelta import relativedelta
from typing import Any, Iterable, Mapping, MutableMapping, Optional

import logging
import requests

from airbyte_cdk.sources.streams.http import HttpStream


logger = logging.getLogger("airbyte")


class SapOdataStream(HttpStream, ABC):
    url_base = "sap/opu/odata/sap"
    query_top = 10  # request size
    query_skip = 0  # initial offset

    def __init__(self, host: str, port: str, **kwargs):
        super().__init__(**kwargs)
        self.url_base = f"{host}:{port}/{self.url_base}/"


    def next_page_token(self, response: requests.Response) -> Optional[Mapping[str, Any]]:
        count = int(response.json().get("d", {}).get("__count", "0"))  # results total count
             
        if self.query_skip < count:
            self.query_skip += self.query_top
            return { "skip": self.query_skip, "count": count }
        else:
            return None


    def request_params(
        self, stream_state: Mapping[str, Any], stream_slice: Mapping[str, any] = None, next_page_token: Mapping[str, Any] = None
    ) -> MutableMapping[str, Any]:
        skip = 0
        count = 0
        if next_page_token:
            if next_page_token["skip"]:
                skip = next_page_token["skip"]
            if next_page_token["count"]:
                count = next_page_token["count"]

        progress = round((skip / count * 100), 2) if count > 0 else round(0, 2)
        logger.info(f"Got {progress}% = {skip} results from {count}...")

        return {
            "$format": "json",
            "$inlinecount": "allpages",
            "$top": self.query_top,
            "$skip": skip
        }


    def parse_response(self, response: requests.Response, **kwargs) -> Iterable[Mapping]:
        data = response.json().get("d", {})  # unwrap data property

        for result in data.get("results", []):            
            result.pop("__metadata", None)
            result.pop("to_PurchaseOrderItem", None)

        return [data]
    
    def make_intervals(
            since: datetime, until: datetime, delta: timedelta
        ) -> list((datetime, datetime)):
        intervals = []

        while since < until:
            increment = since + delta
            intervals.append((since, increment))
            since += delta
        
        return intervals


class BillingDocument(SapOdataStream):
    primary_key = "BillingDocument"

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

    def path(
        self, stream_state: Mapping[str, Any] = None, stream_slice: Mapping[str, Any] = None, next_page_token: Mapping[str, Any] = None
    ) -> str:
        return "ZI_BILLINGDOCUMENTITEMBASIC_SRV/I_BillingDocumentItemBasic"


class ManufacturingOrder(SapOdataStream):
    primary_key = "ManufacturingOrder"

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

    def path(
        self, stream_state: Mapping[str, Any] = None, stream_slice: Mapping[str, Any] = None, next_page_token: Mapping[str, Any] = None
    ) -> str:
        return "ZI_MANUFACTURINGORDER_SRV/I_ManufacturingOrder"


class ProductCost(SapOdataStream):
    primary_key = "ProductCost"
    since = datetime(2020, 1, 1, 0, 0, 0)  # since the begining of data
    until = datetime.combine(datetime.now(), time.max) # until today
    range = relativedelta(days = 1)  # one day
    intervals = []

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.intervals = SapOdataStream.make_intervals(self.since, self.until, self.range)

    def path(
        self, stream_state: Mapping[str, Any] = None, stream_slice: Mapping[str, Any] = None, next_page_token: Mapping[str, Any] = None
    ) -> str:
        interval = self.intervals.pop(0)
        since = (interval[0]).strftime('%Y') + "0" + (interval[0]).strftime('%m')
        until = (interval[1]).strftime('%Y') + "0" + (interval[1]).strftime('%m')

        path = f"C_PRODUCTCOSTBYORDERQUERY_CDS/C_PRODUCTCOSTBYORDERQUERY(P_FromFiscalYearPeriod='{since}',P_ToFiscalYearPeriod='{until}',P_PlanVersion='000',P_TargetCostVariant='000',P_ResultAnalysisVersion='000',P_CurrencyRole='BRL')/Results"
        logger.info(f"ProductCost.path = {path}")
        return path


    def request_params(
        self, stream_state: Mapping[str, Any], stream_slice: Mapping[str, any] = None, next_page_token: Mapping[str, Any] = None
    ) -> MutableMapping[str, Any]:
        return {
            "$format": "json",
            "$inlinecount": "allpages"
        }


    def next_page_token(self, response: requests.Response) -> Optional[Mapping[str, Any]]:
        remaining = len(self.intervals)
        logger.info(f"ProductCost.next_page_token.remaining = {remaining}")
        return { "remaining": remaining } if remaining else None


class PurchaseOrder(SapOdataStream):
    primary_key = "PurchaseOrder"

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

    def path(
        self, stream_state: Mapping[str, Any] = None, stream_slice: Mapping[str, Any] = None, next_page_token: Mapping[str, Any] = None
    ) -> str:
        return "ZI_PURCHASEORDER_API01_SRV/I_PurchaseOrderAPI01"


class SalesBalance(SapOdataStream):
    primary_key = "SalesBalance"
    since = datetime(2020, 1, 1, 0, 0, 0)  # since the begining of data
    until = datetime.combine(datetime.now(), time.max) # until today
    range = relativedelta(days = 1)  # one day
    intervals = []
    plants = []
    plant = ""

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.intervals = SapOdataStream.make_intervals(self.since, self.until, self.range)
        self.plants = ["FL01", "FL02", "FL03", "FL04", "FL05", "FL06", "FL07", "FL08"]
        self.plant = self.plants.pop(0)

    def path(
        self, stream_state: Mapping[str, Any] = None, stream_slice: Mapping[str, Any] = None, next_page_token: Mapping[str, Any] = None
    ) -> str:
        
        if (len(self.intervals) == 0):
            self.plant = self.plants.pop(0)
            self.intervals = SapOdataStream.make_intervals(self.since, self.until, self.range)

        interval = self.intervals.pop(0)
        day = (interval[0]).isoformat(timespec="seconds")

        filter = f"Werks eq '{self.plant}' and Erdat eq datetime'{day}'"
        path = f"ZSDR003_RELATORIO_SALDO_OV_GW_SRV/ZSD_DADOS_TSD001Set?$filter={filter}"
        logger.info(f"SalesBalance.path = {path}")
        return path


    def request_params(
        self, stream_state: Mapping[str, Any], stream_slice: Mapping[str, any] = None, next_page_token: Mapping[str, Any] = None
    ) -> MutableMapping[str, Any]:
        return {
            "$format": "json",
            "$inlinecount": "allpages"
        }


    def next_page_token(self, response: requests.Response) -> Optional[Mapping[str, Any]]:
        plants_remaining = len(self.plants)
        intervals_remaining = len(self.intervals)

        logger.info(f"SalesBalance.next_page_token: plants remaining = {plants_remaining}, intervals remaining = {intervals_remaining}")
        
        if (plants_remaining + intervals_remaining):
            return { "plants": plants_remaining, "intervals": intervals_remaining }
        else:
            return None


class SalesOrder(SapOdataStream):
    primary_key = "SalesOrder"

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

    def path(
        self, stream_state: Mapping[str, Any] = None, stream_slice: Mapping[str, Any] = None, next_page_token: Mapping[str, Any] = None
    ) -> str:
        return "ZI_SALESORDER_SRV/I_SalesOrder"


class TrialBalance(SapOdataStream):
    primary_key = "TrialBalance"
    since = datetime(2020, 1, 1, 0, 0, 0)  # since the begining of data
    until = datetime.combine(datetime.now(), time.max) # until today
    range = relativedelta(days = 1)  # one day
    intervals = []

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.intervals = SapOdataStream.make_intervals(self.since, self.until, self.range)

    def path(
        self, stream_state: Mapping[str, Any] = None, stream_slice: Mapping[str, Any] = None, next_page_token: Mapping[str, Any] = None
    ) -> str:
        interval = self.intervals.pop(0)
        since = (interval[0]).isoformat(timespec="seconds")
        until = (interval[1]).isoformat(timespec="seconds")

        filter = "Ledger eq '0L' and CompanyCode eq 'CM01'"
        select = "GLAccount,GLAccountHierarchyName,FiscalYearPeriod,ProfitCenter,ProfitCenterName,BusinessArea,BusinessAreaName,Segment,Plant,Material,MaterialName,Customer,CustomerName,CompanyCodeCurrency,EndingBalanceAmtInCoCodeCrcy,EndingBalanceAmtInCoCodeCrcy_F,EndingBalanceAmtInCoCodeCrcy_E"

        path = f"C_TRIALBALANCE_CDS/C_TRIALBALANCE(P_FromPostingDate=datetime'{since}',P_ToPostingDate=datetime'{until}')/Results?$filter={filter}&$select={select}"
        logger.info(f"TrialBalance.path = {path}")
        return path


    def request_params(
        self, stream_state: Mapping[str, Any], stream_slice: Mapping[str, any] = None, next_page_token: Mapping[str, Any] = None
    ) -> MutableMapping[str, Any]:
        return {
            "$format": "json",
            "$inlinecount": "allpages"
        }


    def next_page_token(self, response: requests.Response) -> Optional[Mapping[str, Any]]:
        remaining = len(self.intervals)
        logger.info(f"TrialBalance.next_page_token.remaining = {remaining}")
        return { "remaining": remaining } if remaining else None
