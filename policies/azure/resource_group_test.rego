package libredevops.naming.resource_group

import rego.v1

_change(name) := {"resource_changes": [{
	"address": sprintf("azurerm_resource_group.%s", [name]),
	"mode": "managed",
	"type": "azurerm_resource_group",
	"change": {"after": {"name": name}},
}]}

test_warns_on_bad_name if {
	count(warn) == 1 with input as _change("myresourcegroup")
}

test_silent_on_good_name if {
	count(warn) == 0 with input as _change("rg-ldo-uks-prd")
}

test_silent_on_good_name_with_optional_and_number if {
	count(warn) == 0 with input as _change("rg-ldo-uks-prd-mgt-01")
}

test_silent_when_name_unknown if {
	# A computed name is absent from change.after at plan time; nothing to check.
	count(warn) == 0 with input as {"resource_changes": [{
		"address": "azurerm_resource_group.this",
		"mode": "managed",
		"type": "azurerm_resource_group",
		"change": {"after": {}},
	}]}
}

test_ignores_other_resource_types if {
	count(warn) == 0 with input as {"resource_changes": [{
		"address": "azurerm_storage_account.this",
		"mode": "managed",
		"type": "azurerm_storage_account",
		"change": {"after": {"name": "whatever"}},
	}]}
}
