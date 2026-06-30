# METADATA
# title: Resource group naming
# description: >-
#   azurerm_resource_group names should follow the Libre DevOps convention
#   rg-<infix>-<outfix>-<suffix>[-<optional>][-<NN>], for example rg-ldo-uks-prd. Informational
#   (warn): visible in the report but it does not fail the build.
package libredevops.naming.resource_group

import data.lib.naming
import rego.v1

warn contains msg if {
	some offender in naming.offenders(input.resource_changes, "azurerm_resource_group", "rg", "dashed")
	msg := naming.message(offender, "rg", "dashed")
}
