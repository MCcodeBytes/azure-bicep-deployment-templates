param appName string
param appInsightsKey string
param keyVaultName string
param stConnection string
param baseAppSettings object
param funcAppSettings object

param localAppSettings object = {
  APPINSIGHTS_INSTRUMENTATIONKEY: appInsightsKey
  AzureWebJobsStorage: stConnection
  secret1: '@Microsoft.KeyVault(SecretUri=https://${keyVaultName}.vault.azure.net:443/secrets/secret1/)'
}

resource siteconfig 'Microsoft.Web/sites/config@2022-09-01' = {
  name: '${appName}/appSettings'
  properties: union(localAppSettings, baseAppSettings, funcAppSettings)
}
