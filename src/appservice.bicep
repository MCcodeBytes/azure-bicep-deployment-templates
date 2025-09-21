// Creates Function App

param name string
param location string = resourceGroup().location
param kind string
param devopsRg string
param hostingPlanId string
param registryName string
param managedIdentityName string
param keyVaultName string

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: managedIdentityName
  scope: resourceGroup(devopsRg)
}

resource app 'Microsoft.Web/sites@2022-09-01' =  {
  name: name
  location: location
  kind: kind
  identity: {
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    serverFarmId: hostingPlanId
    clientAffinityEnabled: false
    siteConfig: {
      ftpsState: 'Disabled'
      alwaysOn: true
      minTlsVersion: '1.2'
      acrUseManagedIdentityCreds: true
      acrUserManagedIdentityID: managedIdentity.properties.clientId
      linuxFxVersion: registryName
      cors:{
        allowedOrigins: [
          'https://portal.azure.com'
        ]
        supportCredentials: false
      }
    }
    httpsOnly: true
    vnetImagePullEnabled: true


  }
}

resource appFTP 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-09-01' = {
  name: 'ftp'
  kind: kind
  parent: app
  properties: {
    allow: false
  }
}

resource appSCM 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-09-01' = {
  name: 'scm'
  kind: kind
  parent: app
  properties: {
    allow: false
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}

resource keyVaultAccess 'Microsoft.KeyVault/vaults/accessPolicies@2018-02-14' = {
  parent: keyVault
  name: 'add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: app.identity.principalId
        permissions: {
          keys: []
          secrets: [
            'get'
          ]
          certificates: []
          storage: []
        }
      }
    ]
  }
}
