package libredevops.naming.key_vault

import rego.v1

_c(name) := {"resource_changes": [{
	"address": sprintf("azurerm_key_vault.%s", [name]),
	"mode": "managed",
	"type": "azurerm_key_vault",
	"change": {"after": {"name": name}},
}]}

test_warns_on_bad_name if {
	count(warn) == 1 with input as _c("badname")
}

test_silent_on_good_name if {
	count(warn) == 0 with input as _c("kv-ldo-uks-prd-01")
}

test_silent_when_name_unknown if {
	count(warn) == 0 with input as {"resource_changes": [{
		"address": "azurerm_key_vault.this", "mode": "managed", "type": "azurerm_key_vault",
		"change": {"after": {}},
	}]}
}
