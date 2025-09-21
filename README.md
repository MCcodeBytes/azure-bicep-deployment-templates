# Project infra: full-stack Bicep deployment

This repository contains a set of Bicep templates that provision application infrastructure in Azure. The templates are intentionally generic and use placeholder values so the repo can be published publicly.

## What this repository provisions
- A Storage Account (with containers and queues)
- Application Insights and Log Analytics workspaces
- An Azure Key Vault and a secret
- Private endpoints for storage account blob & queue and key vault (note: DNS configuration is not handled by the templates)
- App Service / Function App instances and their app settings

## Files of interest
- `src/main.bicep` — main orchestration template (resourceGroup scope)
- `src/storageaccount.bicep` — storage account module
- `src/keyvault.bicep` — key vault module
- `src/privateEndpoint.bicep` — private endpoint module
- `src/appservice.bicep` — app/service module
- `src/appsettings/funcApp.bicep` — function app settings module
- `src/appsettings/webApp.bicep` — web app settings module
- `src/Parameters-Dev.bicepparam` — example parameter file for Dev


## Secrets and placeholders
- All secrets should be provided as secure parameters at deployment time. `keyvault.bicep` expects `secret1` (annotated with `@secure()`).
- The parameter files in `src/` use placeholders for subscription IDs, resource group names, private IPs, and registry hosts. Replace them with your own values before deploying.


## How to deploy (example, `pwsh` / Azure CLI)

1. Log in and set the target subscription

```pwsh
az login
az account set --subscription <SUBSCRIPTION_ID>
```

2. Deploy the template to a resource group (example)

```pwsh
az deployment group create \
  --resource-group <your-rg> \
  --template-file src/main.bicep \
  --parameters parameters-dev.bicepparam
```

## Creating multiple combinations of web and function apps (loops)

The `main.bicep` template uses arrays for `appService` and `appServiceNames` and iterates over `appService` to create App Service / Function App instances. You can leverage Bicep's loop constructs to provision many combinations of web and function apps.

Example: deploy multiple combinations by providing `appService` as an array of definitions in your parameter file:

```bicep
param appService = [
  {
    name: 'func-orders'
    kind: 'functionapp'
    registryName: 'DOCKER|<REGISTRY>/orders:latest'
  }
  {
    name: 'app-portal'
    kind: 'app'
    registryName: 'DOCKER|<REGISTRY>/portal:latest'
  }
  // add more entries as needed
]

// In main.bicep the module is already written as a loop:
// module appservice './appservice.bicep' = [for app in appService: { ... }]

// To create pairings (e.g., one web app per function app or vice versa) you can compose arrays programmatically
// and use nested loops or map inputs accordingly. Example snippet to create a derived "deploymentSet":

var deploymentSets = [for w in appService: if (w.kind == 'app') {
  web: w
  // find an associated function app by some naming convention or mapping
  functions: [for f in appService: if (contains(f.name, 'func-')) f]
}]

// Then iterate deploymentSets to configure settings or create dependencies.

This approach keeps your templates data-driven: add or remove entries in the parameter file to change the set of apps deployed without modifying templates.

## Use loops everywhere (recommended)

Bicep is designed to be data-driven. Wherever possible, model resources as arrays in parameter files and use loops in modules to create many instances from a single module. This reduces template duplication and makes the repo easier to maintain.

Common modules to iterate over:
- Storage account containers/queues (`storageaccount.bicep`) — create containers/queues with a loop.
- Logs / App Insights (`logs.bicep`) — provide an array of logResources and create each with a loop.
- Private endpoints (`privateEndpoint.bicep`) — pass `networks` as an array and create private endpoints with a loop (already done in `main.bicep`).
- App Service / Function Apps (`appservice.bicep`) — provision apps from an `appService` array.
- App settings modules (`appsettings/*.bicep`) — call modules in a loop or for specific named apps.

Example patterns:

Create containers/queues in `storageaccount.bicep`:

```bicep
resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: uniqueStorageName
  ...
}

// create containers
[for c in containerName: resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  name: '${storage.name}/default/${c}'
  properties: {}
}]

// create queues
[for q in queueName: resource queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-04-01' = {
  name: '${storage.name}/default/${q}'
}]
```

Create App Services from `appService` array (already demonstrated):

```bicep
module appservice './appservice.bicep' = [for app in appService: {
  name: 'functionapp-${app.name}'
  params: {
    name: app.name
    kind: app.kind
    registryName: app.registryName
  }
}]
```

Create private endpoints from `networks` array (main.bicep uses this pattern already):

```bicep
module privateEndpointModule './privateEndpoint.bicep' = [for network in networks : {
  name: network.privateEndpointName
  params: {
    privateEndpointSubnetId: network.privateEndpointSubnetId
    privateEndpointFQDN: network.privateEndpointFQDN
  }
}]
```

Using loops everywhere makes templates predictable and lets you scale the number of resources by changing parameter arrays only.

