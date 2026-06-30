# METADATA
# title: Key vault naming
# description: >-
#   azurerm_key_vault names should follow the Libre DevOps convention (kv-ldo-uks-prd-01). Informational (warn): visible in the
#   report but it does not fail the build.
package libredevops.naming.key_vault

import data.lib.naming
import rego.v1

warn contains msg if {
	some offender in naming.offenders(input.resource_changes, "azurerm_key_vault", "kv", "dashed")
	msg := naming.message(offender, "kv", "dashed")
}
