# Commit Message Format

This repo uses [Conventional Commits](https://www.conventionalcommits.org/).

```
<type>(<scope>): <description>
```

## Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `chore` | Maintenance, deps, formatting |
| `refactor` | Code restructuring |
| `ci` | CI/CD changes |
| `revert` | Reverting changes |

## Scopes (optional)

- Host names: `puppypc`, `thekennel`, `thedogpark`, `mistylappytappy`
- Components: `workflows`, `flake`, `deps`, `nginx`, etc.

## Examples

```
feat(thekennel): add jellyfin service
fix(workflows): correct build path
chore(deps): update flake inputs
ci: add topology diagram workflow
```
