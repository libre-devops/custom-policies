<div align="center">

<a href="https://libredevops.org">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://libredevops.org/assets/libre-devops-white.png">
    <img alt="Libre DevOps" src="https://libredevops.org/assets/libre-devops-black.png" width="300">
  </picture>
</a>

# Custom Policies

Conftest/OPA (Rego) policies for Libre DevOps Terraform, starting with the Azure naming convention.

[![CI](https://github.com/libre-devops/custom-policies/actions/workflows/ci.yml/badge.svg)](https://github.com/libre-devops/custom-policies/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/libre-devops/custom-policies?sort=semver&label=release)](https://github.com/libre-devops/custom-policies/releases/latest)
[![License](https://img.shields.io/github/license/libre-devops/custom-policies)](./LICENSE)

</div>

---

> **Status: active development.** Interfaces may change until the first tagged release.

## Overview

These are [Conftest](https://www.conftest.dev/) / [OPA](https://www.openpolicyagent.org/) policies
written in Rego and evaluated against a Terraform plan rendered to JSON
(`terraform show -json plan.bin > plan.json`). The plan JSON exposes the real resource name values
(`resource_changes[].change.after.name`), which is what a naming convention checks, so this is the
right layer for it (Trivy's config scanner does not expose resource names).

The first policy set enforces the
[Libre DevOps Azure naming convention](https://libredevops.org/docs/documents/azure-naming-convention):
`${prefix}-${infix}-${outfix}-${suffix}[-${optional}][-${numbering}]` for dashed resources (for
example `rg-ldo-uks-prd`), and the no-dash form for resources that prohibit hyphens (storage
accounts, VMs: `saldouksprd01`).

Naming checks are **informational**: they are Conftest `warn` rules, so they are listed in the
report but do not fail the build. Hard, build-failing rules would be `deny` rules.

## Layout

```
policies/
  lib/naming.rego          shared convention helpers (regex parts, valid(), offenders(), message())
  azure/<resource>.rego    one file per resource type (resource_group, virtual_network, ...)
  azure/<resource>_test.rego  Rego unit tests for that resource
```

One file per resource keeps the set maintainable as every resource type in the convention is added
over time.

## Usage

Render a plan to JSON and evaluate the policies against it:

```bash
terraform plan -out plan.bin
terraform show -json plan.bin > plan.json
conftest test plan.json --policy policies --all-namespaces
```

Or via `just` (needs [`just`](https://github.com/casey/just) and `conftest`):

- `just test` runs the Rego unit tests (hermetic, no cloud or real plan needed).
- `just check plan.json` evaluates the policies against a plan JSON.
- `just fmt` / `just fmt-check` format the Rego.

## Adding a resource

1. Create `policies/azure/<resource>.rego` in package `libredevops.naming.<resource>`, importing
   `data.lib.naming`, and emit a `warn` from `naming.offenders(...)` with the resource's prefix slug
   and dash style (`"dashed"`, `"nodash"`, or `"subnet"`).
2. Add `policies/azure/<resource>_test.rego` with a good name, a bad name, and an unknown-name case.
3. Run `just test`.

## Contributing

Issues and pull requests are welcome. Please read the
[Libre DevOps standards](https://libredevops.org/docs/documents) and keep changes consistent with
them. Run `just test` before opening a pull request.

## License

Released under the [MIT License](./LICENSE).

---

<div align="center">
<sub>
Part of <a href="https://libredevops.org">Libre DevOps</a>: free, open, and opinionated DevOps
tooling and standards. This project is provided as-is, without warranty; review and test it
against your own requirements before use in production.
</sub>
</div>
