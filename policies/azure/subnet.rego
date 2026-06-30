# METADATA
# title: Subnet naming
# description: >-
#   azurerm_subnet names should follow the Libre DevOps convention (snet-app-vnet-ldo-uks-prd-01). Informational (warn): visible in the
#   report but it does not fail the build.
package libredevops.naming.subnet

import data.lib.naming
import rego.v1

warn contains msg if {
	some offender in naming.offenders(input.resource_changes, "azurerm_subnet", "snet", "subnet")
	msg := naming.message(offender, "snet", "subnet")
}
