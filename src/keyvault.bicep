param keyVaultName string
param location string = resourceGroup().location
param tenantId string = subscription().tenantId
param objectId string
param secretsPermissions array
@secure()
param secret1 string

resource keyVault 'Microsoft.KeyVault/vaults@2024-12-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    accessPolicies: [
      {
        objectId: objectId
        tenantId: tenantId
        permissions: {
          secrets: secretsPermissions
        }
      }
    ]
    tenantId: tenantId
    enabledForTemplateDeployment: true
    enablePurgeProtection: true
    enableRbacAuthorization: false
    enableSoftDelete: true
    publicNetworkAccess: 'disabled'
    softDeleteRetentionInDays: 90
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

resource secretX 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: 'secret1Key'
  properties: {
    value: secret1
  }
}
