# Publish Configuration for `zuraffa_dashboard`

<!-- Ported from the zuraffa_permissions pipeline (publish-manager flow). -->

## Package Manager

- **Type**: `pub.dev`
- **Packages** (in publish order — app package first, the federated adapters declare it hosted):
1. `zuraffa_dashboard`
2. `zuraffa_dashboard_platform_interface`
3. `zuraffa_dashboard_android`
4. `zuraffa_dashboard_ios`
5. `zuraffa_dashboard_macos`
- **All packages are public**

## Scripts

- **Pre-publish**: `./scripts/prepare_for_publish.sh <version>` — creates `publish-<version>` branch, bumps all package versions + in-family constraints, propagates the root CHANGELOG entry into each package, commits
- **Publish**: `./scripts/publish.sh` — dry-run + publish per package in order, waits for pub.dev propagation (needs flutter/dart on PATH)
- **Post-publish**: `./scripts/push_to_master.sh -f` — merges the publish branch to master, tags, pushes, deletes the branch
- **Restore dev**: not needed — `dependency_overrides` are stripped by pub on publish; nothing to convert back

## Workflow

1. Write the release notes as a `## <version>` entry at the TOP of the root `CHANGELOG.md`
2. `./scripts/prepare_for_publish.sh <version>`
3. `git push origin publish-<version>`
4. `bash scripts/publish.sh` (allow 10-30 min: propagation waits between packages)
5. `bash scripts/push_to_master.sh -f`

## Notes

- `zikzak`-style sibling path overrides never need converting: pub ignores `dependency_overrides` when publishing.
- The example app resolves siblings through its own `dependency_overrides` and is never published.
- Pre-flight sanity: `dart test` in `packages/zuraffa_dashboard`, `flutter test` in the other packages, `dart analyze` everywhere.
