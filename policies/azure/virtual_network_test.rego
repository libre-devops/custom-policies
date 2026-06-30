package libredevops.naming.virtual_network

import rego.v1

_c(name) := {"resource_changes": [{
	"address": sprintf("azurerm_virtual_network.%s", [name]),
	"mode": "managed",
	"type": "azurerm_virtual_network",
	"change": {"after": {"name": name}},
}]}

test_warns_on_bad_name if {
	count(warn) == 1 with input as _c("badname")
}

test_silent_on_good_name if {
	count(warn) == 0 with input as _c("vnet-ldo-uks-prd-01")
}

test_silent_when_name_unknown if {
	count(warn) == 0 with input as {"resource_changes": [{
		"address": "azurerm_virtual_network.this", "mode": "managed", "type": "azurerm_virtual_network",
		"change": {"after": {}},
	}]}
}
