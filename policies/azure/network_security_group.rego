# METADATA
# title: Network security group naming
# description: >-
#   azurerm_network_security_group names should follow the Libre DevOps convention (nsg-ldo-uks-prd-01). Informational (warn): visible in the
#   report but it does not fail the build.
package libredevops.naming.network_security_group

import data.lib.naming
import rego.v1

warn contains msg if {
	some offender in naming.offenders(input.resource_changes, "azurerm_network_security_group", "nsg", "dashed")
	msg := naming.message(offender, "nsg", "dashed")
}
