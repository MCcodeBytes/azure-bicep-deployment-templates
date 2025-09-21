// Creates Storage Account

param storageSKU string
param location string = resourceGroup().location
param containerName array
param uniqueStorageName string
param queueName array

resource stg 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: uniqueStorageName
  location: location
  sku: {
    name: storageSKU
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: 'Disabled'
    minimumTlsVersion: 'TLS1_2'
  }

  resource blobSvc 'blobServices' = {
    name: 'default' 

  // Creates containers
    resource containers 'containers' = [for name in containerName: {
      name: name
      properties: {
        publicAccess: 'None'
      }
    }]
  }

  resource queueSvc 'queueServices' = {
    name: 'default' 

  // Creates containers
    resource queues 'queues' = [for name in queueName: {
      name: name
    }]
  }

  // Add management policy for lifecycle
  resource mgmtPolicy 'managementPolicies' = {
    name: 'default'
    properties: {
      policy: {
        rules: [
          {
            name: 'expire-passes'
            enabled: true
            type: 'Lifecycle'
            definition: {
              filters: {
                blobTypes: ['blockBlob']
                prefixMatch: ['passes/']
              }
              actions: {
                baseBlob: {
                  delete: {
                    daysAfterCreationGreaterThan: 90
                  }
                }
              }
            }
          }
        ]
      }
    }
  }
}

var stconnectionstring = 'DefaultEndpointsProtocol=https;AccountName=${stg.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(stg.id, stg.apiVersion).keys[0].value}'
output stconnectionstring string = stconnectionstring
