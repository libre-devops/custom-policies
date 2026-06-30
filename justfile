# Libre DevOps custom-policies task runner. Run `just` to list recipes.
#
# Install just with either:
#   brew install just
#   uv tool add rust-just     # then call recipes as: uv run just <recipe>
#
# Policies are Conftest/OPA (Rego) checks evaluated against a Terraform plan rendered to JSON
# (`terraform show -json plan.bin > plan.json`). Naming checks are informational `warn` rules: they
# surface in the report but do not fail the build. Install conftest with `brew install conftest`.

set shell := ["pwsh", "-NoProfile", "-Command"]

# Tag prefix. Empty so tags are plain semver (1.2.3); the action pins this repo by tag.
tag_prefix := ""

# List available recipes.
default:
    just --list

# Format every Rego file in place.
fmt:
    conftest fmt policies

# Fail if any Rego file is not formatted.
fmt-check:
    conftest fmt --check policies

# Run the Rego unit tests (hermetic; no cloud or real plan needed).
test:
    conftest verify --policy policies

# Evaluate the policies against a Terraform plan JSON. Example: just check plan.json
check plan="plan.json":
    conftest test '{{ plan }}' --policy policies --all-namespaces

# --- Release management -------------------------------------------------------------------
# Tags are plain semver (1.2.3). Pass a bare version like 1.2.3; the tag_prefix variable (empty
# here) is applied automatically.

# Create and push an annotated tag. Example: just tag 1.2.3
tag version:
    git tag -a '{{ tag_prefix }}{{ version }}' -m 'Release {{ tag_prefix }}{{ version }}'
    git push origin '{{ tag_prefix }}{{ version }}'

# Bump the latest semver tag and push the new tag. level = patch (default), minor, or major.
increment-tag level="patch":
    $p = '{{ tag_prefix }}'; $re = '^' + [regex]::Escape($p) + '\d+\.\d+\.\d+$'; $tags = @(git tag --list | Where-Object { $_ -match $re }); $cur = if ($tags.Count -eq 0) { [version]'0.0.0' } else { ($tags | ForEach-Object { [version]($_.Substring($p.Length)) } | Sort-Object)[-1] }; $next = switch ('{{ level }}') { 'major' { "$($cur.Major + 1).0.0" } 'minor' { "$($cur.Major).$($cur.Minor + 1).0" } 'patch' { "$($cur.Major).$($cur.Minor).$($cur.Build + 1)" } default { throw 'level must be patch, minor, or major' } }; $tag = "$p$next"; git tag -a $tag -m "Release $tag"; git push origin $tag; Write-Host "Tagged and pushed $tag"

# Create a GitHub release from an existing tag, with auto-generated notes. Example: just release 1.2.3
release version:
    gh release create '{{ tag_prefix }}{{ version }}' --title '{{ tag_prefix }}{{ version }}' --generate-notes

# Tag a specific version and release it. Example: just tag-and-release 1.2.3
tag-and-release version:
    git tag -a '{{ tag_prefix }}{{ version }}' -m 'Release {{ tag_prefix }}{{ version }}'
    git push origin '{{ tag_prefix }}{{ version }}'
    gh release create '{{ tag_prefix }}{{ version }}' --title '{{ tag_prefix }}{{ version }}' --generate-notes

# Bump the latest tag, push it, and create a release. level = patch (default), minor, or major.
increment-release level="patch":
    $p = '{{ tag_prefix }}'; $re = '^' + [regex]::Escape($p) + '\d+\.\d+\.\d+$'; $tags = @(git tag --list | Where-Object { $_ -match $re }); $cur = if ($tags.Count -eq 0) { [version]'0.0.0' } else { ($tags | ForEach-Object { [version]($_.Substring($p.Length)) } | Sort-Object)[-1] }; $next = switch ('{{ level }}') { 'major' { "$($cur.Major + 1).0.0" } 'minor' { "$($cur.Major).$($cur.Minor + 1).0" } 'patch' { "$($cur.Major).$($cur.Minor).$($cur.Build + 1)" } default { throw 'level must be patch, minor, or major' } }; $tag = "$p$next"; git tag -a $tag -m "Release $tag"; git push origin $tag; gh release create $tag --title $tag --generate-notes; Write-Host "Released $tag"

# Bump, tag, and release in one step (same as increment-release). Example: just increment-tag-and-release minor
increment-tag-and-release level="patch":
    just increment-release {{ level }}

# Force-update a tag to a ref and push it (literal tag), for example to move a moving major alias.
force-push-tag tag ref="HEAD":
    git tag -f '{{ tag }}' '{{ ref }}'
    git push -f origin '{{ tag }}'
    @echo "Force-pushed {{ tag }} to {{ ref }}"
