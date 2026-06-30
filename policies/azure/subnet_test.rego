package libredevops.naming.subnet

import rego.v1

_c(name) := {"resource_changes": [{
	"address": sprintf("azurerm_subnet.%s", [name]),
	"mode": "managed",
	"type": "azurerm_subnet",
	"change": {"after": {"name": name}},
}]}

test_warns_on_bad_name if {
	count(warn) == 1 with input as _c("subnet1")
}

test_silent_on_good_name if {
	count(warn) == 0 with input as _c("snet-app-vnet-ldo-uks-prd-01")
}

test_silent_when_name_unknown if {
	count(warn) == 0 with input as {"resource_changes": [{
		"address": "azurerm_subnet.this", "mode": "managed", "type": "azurerm_subnet",
		"change": {"after": {}},
	}]}
}
