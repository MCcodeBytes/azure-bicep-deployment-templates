using './main.bicep'

param resourceGroups = {
  appRg: 'rg-app-dev-eu2'
  devopsRg: 'rg-devops-np-eu2'
  managedIdentity: 'id-managedidentity-np-eu2'
  appServiceHostPlan: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-xxx-np-eu2/providers/Microsoft.Web/serverFarms/asp-xxx-np-eu2'
}

param storageAccount = {
  name: 'stg-app-dev'
  SKU: 'Standard_LRS'
  containers: ['container1','container2']
  queues: ['queue1', 'queue2']
}

param logResources = [
  {
    appInsightsName : 'appi-app-dev-eu2'
    logAnalyticsName : 'log-app-dev-eu2'
  }
]

param keyVault = {
  name : 'kv-app-dev'
  objectId : '00000000-0000-0000-0000-000000000000'
  secretsPermissions : ['get', 'list', 'delete']
}

param networks = [
  {
    privateEndpointSubnetId : '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/subnet-private'
    privateEndpointName: 'pe-blob-stg-app-dev'
    privateEndpointGroupId: 'blob'
    privateEndpointmemberName: 'blob'
    privateEndpointIp: '10.0.0.10'
    privateEndpointFQDN: 'stg-app-dev.blob.core.windows.net'
  }
  {
    privateEndpointSubnetId : '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/subnet-private'
    privateEndpointName: 'pe-queue-stg-app-dev'
    privateEndpointGroupId: 'queue'
    privateEndpointmemberName: 'queue'
    privateEndpointIp: '10.0.0.11'
    privateEndpointFQDN: 'stg-app-dev.queue.core.windows.net'
  }
  {
    privateEndpointSubnetId : '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-example/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/subnet-private'
    privateEndpointName: 'pe-kv-app-dev'
    privateEndpointGroupId: 'vault'
    privateEndpointmemberName: 'default'
    privateEndpointIp: '10.0.0.12'
    privateEndpointFQDN: 'kv-app-dev.vault.azure.net'
  }
]

param appService = [
  {
    name: 'func-sample1-dev-eu2'
    kind: 'functionapp'
    registryName: 'DOCKER|<REGISTRY>/<REPO>:<TAG>)'
  }
  {
    name: 'app-sample2-dev-eu2'
    kind: 'app'
    registryName: 'DOCKER|<REGISTRY>/<REPO>:<TAG>)'
  }  
]

param appServiceNames = {
  funcAppName: 'func-sample1-dev-eu2'
  webAppName: 'app-sample2-dev-eu2'
}

param baseAppSettings = {
  WEBSITE_VNET_ROUTE_ALL : '1'
  WEBSITES_ENABLE_APP_SERVICE_STORAGE : 'false'
  DOCKER_REGISTRY_SERVER_URL : 'https://<REGISTRY>.azurecr.io'
}

param funcAppSettings = {
  FUNCTIONS_EXTENSION_VERSION : '~4'
  AZURE_FUNCTIONS_ENVIRONMENT : 'Development'
  variable1 : 'value1'
}

param webAppSettings = {
  variableA : 'valueA'
}

param secret1 = ''

param defaultConnectionString = 'Data Source=sql-server.example.net; Initial Catalog=APPDB-dev;Authentication=Active Directory Managed Identity;'


