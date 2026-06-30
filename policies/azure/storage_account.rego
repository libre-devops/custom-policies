# METADATA
# title: Storage account naming
# description: >-
#   azurerm_storage_account names should follow the Libre DevOps convention (saldouksprd01). Informational (warn): visible in the
#   report but it does not fail the build.
package libredevops.naming.storage_account

import data.lib.naming
import rego.v1

warn contains msg if {
	some offender in naming.offenders(input.resource_changes, "azurerm_storage_account", "sa", "nodash")
	msg := naming.message(offender, "sa", "nodash")
}
