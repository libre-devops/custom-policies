# METADATA
# title: Libre DevOps naming convention helpers
# description: >-
#   Shared building blocks for the Libre DevOps Azure naming convention
#   (https://libredevops.org/docs/documents/azure-naming-convention). Per-resource policies import
#   this library and call valid() with the resource's prefix slug and dash style, so the convention
#   lives in one place and each resource file stays small.
package lib.naming

import rego.v1

# Approved environment stage codes (the suffix element).
env_codes := {"poc", "mvp", "dev", "tst", "stg", "uat", "ppd", "prd"}

# Regex fragments for the structured name parts (all lower case).
#   infix:     2-4 char product/team code
#   outfix:    2-3 char Azure region code (uks, euw, ...)
#   optional:  short functional qualifier (mgt, sec, ...)
#   numbering: zero-padded ordinal
infix_re := `[a-z0-9]{2,4}`

outfix_re := `[a-z]{2,3}`

optional_re := `[a-z]{2,4}`

numbering_re := `[0-9]{2,}`

# Alternation of the approved environment codes, for example (poc|mvp|dev|...).
env_re := sprintf("(%s)", [concat("|", [code | some code in env_codes])])

# Dashed construct: ${prefix}-${infix}-${outfix}-${suffix}[-${optional}][-${numbering}].
# Used by most resources. The prefix slug is passed without its trailing dash.
dashed_re(prefix) := sprintf("^%s-%s-%s-%s(-%s)?(-%s)?$", [prefix, infix_re, outfix_re, env_re, optional_re, numbering_re])

# No-dash construct: ${prefix}${infix}${outfix}${suffix}[${optional}][${numbering}].
# Used by resources that prohibit hyphens (storage accounts, VMs, ...).
nodash_re(prefix) := sprintf("^%s%s%s%s(%s)?(%s)?$", [prefix, infix_re, outfix_re, env_re, optional_re, numbering_re])

# Subnet construct: snet-${purpose}-${parent vnet name}, for example
# snet-app-vnet-ldo-uks-prd-01. The parent vnet name itself follows the dashed vnet convention.
subnet_re := sprintf("^snet-[a-z0-9]+-vnet-%s-%s-%s(-%s)?$", [infix_re, outfix_re, env_re, numbering_re])

# valid(name, prefix, style) is true when name fits the convention for the given dash style.
valid(name, prefix, "dashed") if regex.match(dashed_re(prefix), name)

valid(name, prefix, "nodash") if regex.match(nodash_re(prefix), name)

valid(name, _, "subnet") if regex.match(subnet_re, name)

# Human-readable expected form, used in warning messages.
expected(prefix, "dashed") := sprintf("%s-<infix>-<outfix>-<suffix>[-<optional>][-<NN>]", [prefix])

expected(prefix, "nodash") := sprintf("%s<infix><outfix><suffix>[<optional>][<NN>]", [prefix])

expected(_, "subnet") := "snet-<purpose>-vnet-<infix>-<outfix>-<suffix>[-<NN>]"

# offenders(changes, tf_type, prefix, style) returns {address, name} objects for managed resources
# of tf_type whose name is known at plan time and does not satisfy the convention. Resources whose
# name is unknown (computed) at plan time are skipped: there is nothing to check yet.
offenders(changes, tf_type, prefix, style) := {obj |
	some rc in changes
	rc.mode == "managed"
	rc.type == tf_type
	name := rc.change.after.name
	is_string(name)
	not valid(name, prefix, style)
	obj := {"address": rc.address, "name": name}
}

# message(offender, prefix, style) is the standard informational warning text.
message(offender, prefix, style) := sprintf(
	"naming (info): %s name %q does not match %s",
	[offender.address, offender.name, expected(prefix, style)],
)
