# METADATA
# title: Virtual network naming
# description: >-
#   azurerm_virtual_network names should follow the Libre DevOps convention (vnet-ldo-uks-prd-01). Informational (warn): visible in the
#   report but it does not fail the build.
package libredevops.naming.virtual_network

import data.lib.naming
import rego.v1

warn contains msg if {
	some offender in naming.offenders(input.resource_changes, "azurerm_virtual_network", "vnet", "dashed")
	msg := naming.message(offender, "vnet", "dashed")
}
