from abc import ABC
from typing import Any, List, Mapping, Tuple

import logging
import requests
from requests.auth import HTTPBasicAuth

from airbyte_cdk.sources import AbstractSource
from airbyte_cdk.sources.streams import Stream

from source_sap_odata.streams import BillingDocument, ManufacturingOrder, ProductCost, PurchaseOrder, SalesBalance, SalesOrder, TrialBalance

logger = logging.getLogger("airbyte")


class SourceSapOdata(AbstractSource):
    def check_connection(self, logger, config) -> Tuple[bool, any]:
        logger.info("Checking SAP OData service connection...")

        host = config["host"]
        port = config["port"]
        odata = "/sap/opu/odata/iwfnd/catalogservice;v=2"
        query = "$format=json"
        basic = HTTPBasicAuth(config["username"], config["password"])
        response = requests.get(url=f"{host}:{port}{odata}?{query}", auth=basic)

        if response.status_code == 200: # OK
            logger.info(f"SAP OData service connection success!")
            return True, None
        else:
            logger.info(f"SAP OData service connection failure: {response.status_code}")
            return False, response.json()

    def streams(self, config: Mapping[str, Any]) -> List[Stream]:
        basic = HTTPBasicAuth(config["username"], config["password"])
        
        args = {
            "authenticator": basic,
            "host": config["host"],
            "port": config["port"]
        }

        return [
            BillingDocument(**args),
            ManufacturingOrder(**args),
            ProductCost(**args),
            PurchaseOrder(**args),
            SalesBalance(**args),
            SalesOrder(**args),
            TrialBalance(**args)
        ]
