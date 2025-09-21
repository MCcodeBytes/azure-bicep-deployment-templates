param location string = resourceGroup().location
param privateEndpointName string
param privateEndpointSubnetId string
param privateEndpointGroupId string
param uniqueStorageName string
param keyVaultName string
param privateEndpointmemberName string
param privateEndpointIp string
param privateEndpointFQDN string

resource stg 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: uniqueStorageName
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = if (privateEndpointGroupId == 'vault') {
  name: keyVaultName
}

var privateLinkServiceId = ((privateEndpointGroupId == 'vault') ? keyVault.id : stg.id)

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    customNetworkInterfaceName: '${privateEndpointName}-nic'
    privateLinkServiceConnections: [
      {
        name: '${privateEndpointName}-service-link-connection'
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: [
            '${privateEndpointGroupId}'
          ]
        }
      }
    ]
    ipConfigurations: [
      {
        name: 'staticIP'
        properties: {
          groupId: privateEndpointGroupId
          memberName: privateEndpointmemberName
          privateIPAddress: privateEndpointIp
        }
      }
    ]
    customDnsConfigs: [
      {
        fqdn: privateEndpointFQDN
        ipAddresses: [
          '${privateEndpointIp}'
        ]
      }
    ]
  }
}
