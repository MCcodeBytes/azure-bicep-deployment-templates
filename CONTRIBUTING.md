# Contributing — secure practices

Thanks for contributing! This repository contains infrastructure-as-code (Bicep) templates and parameter files. Before submitting pull requests, please follow these guidelines to keep secrets and sensitive information out of the repository.

## Do NOT commit secrets or credentials
- Never commit secrets, passwords, access tokens, service principal credentials, or private keys to the repository. This includes connection strings, Key Vault secret values, and any ACR pull/push credentials.
- If you accidentally commit a secret, rotate the secret immediately in the target system and remove it from the git history (tools: `git filter-repo`, `git rebase -i`).

## Use parameter files with placeholders
- Parameter files in `src/` should only contain placeholder values (for example: `<SUBSCRIPTION_ID>`, `<REGISTRY_HOST>`, `<SERVICE_PRINCIPAL_OBJECT_ID>`).

## CI/CD and pipeline secrets
- Configure secrets in your CI/CD provider's secure secret store (GitHub Actions Secrets, Azure DevOps variable groups, etc.).
- Do not echo secrets in logs. Use masked secrets features and `--no-logs` equivalents when available.

## Use Azure Key Vault for runtime secrets
- Pass secrets (passwords, API keys, connection strings) to be stored in Azure Key Vaul at runtime while deploying with GitHub Actions or CD pipeline
- Provide parameter placeholders that reference Key Vault secret URIs where appropriate. Example in app settings:
  - `@Microsoft.KeyVault(SecretUri=https://<KEYVAULT_NAME>.vault.azure.net:443/secrets/<SECRET_NAME>/)`

## PR checklist
- [ ] No secrets in diffs (connection strings, keys, tokens).
- [ ] Parameter files contain placeholders only.
- [ ] Document any new required environment variables or secrets in the README.
- [ ] If new CI steps are added, ensure they reference secrets from the CI provider and not repository files.

If you need help setting up Key Vault references or CI secrets, open an issue or request guidance in the PR and include the minimal details required (no secrets). Thank you!