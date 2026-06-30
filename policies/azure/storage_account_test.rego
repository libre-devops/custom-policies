package libredevops.naming.storage_account

import rego.v1

_c(name) := {"resource_changes": [{
	"address": sprintf("azurerm_storage_account.%s", [name]),
	"mode": "managed",
	"type": "azurerm_storage_account",
	"change": {"after": {"name": name}},
}]}

test_warns_on_bad_name if {
	count(warn) == 1 with input as _c("mystorageaccount")
}

test_silent_on_good_name if {
	count(warn) == 0 with input as _c("saldouksprd01")
}

test_silent_when_name_unknown if {
	count(warn) == 0 with input as {"resource_changes": [{
		"address": "azurerm_storage_account.this", "mode": "managed", "type": "azurerm_storage_account",
		"change": {"after": {}},
	}]}
}
